extends Control

const matrix_protocol = preload( "Matrix.gd" )

export(String) var user_username
export(String) var user_password

#var access_token := ""
var login := false
var mp : MatrixProtocol
var room_counter := 0
var joined_rooms := {}
var synced_data := {}
var input_text := ""
var current_room = ""
var next_batch := ""
var previous_batch := ""

onready var channel_name := $Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/ChannelName
onready var topic := $Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/Topic
onready var room_list := $Screen/LeftSection/ItemList
onready var chat_line := $Screen/MidSection/ChatInput/ChatLineStretcher/ChatLine
onready var chat_window := $Screen/MidSection/ChatWindow
onready var chat_history_list := null
onready var login_status := $LoginScreen/CenterContainer/VBoxContainer/LoginStatus
onready var username := $LoginScreen/CenterContainer/VBoxContainer/GridContainer/Username
onready var password := $LoginScreen/CenterContainer/VBoxContainer/GridContainer/Password
onready var modal := $Modal
onready var popup := $PopUps


# Login a user
func _on_Login_pressed():
	# Proper login code.
#	mp.login(username.text, password.text)
	# Speeds up debug.
	mp.login(user_username, user_password)
	login_status.text = "Attempting login..."


# Logout
func _on_Logout_pressed():
	modal.hide()
	$Timer.stop()
	mp.logout()
	joined_rooms.clear()
	room_list.clear()
	room_counter = 0
	chat_window.clear()
	login_status.text = "Logged out."
	$LoginScreen.show()


# Register a new user.
# TODO : Figure out how to register a user
# TODO : Implement registration.
func _on_Register_pressed():
	mp.register()
	login_status.text = "Sorry, registration is not implemented!"


func _on_Settings_pressed():
	modal.find_node("Settings").appear()


# Open create room popup
func _on_CreateRoom_pressed():
	popup.find_node("CreateRoom").popup_centered()


# Call for room creation.
# NOTE : I should seriously start thinking about
#	turning mp into a singleton at this rate.
# TODO : Something is broken here. Matrix side works fine, but the result
#	is not added to my list of available rooms for some reason.
func _on_CreateRoom_create_room(room_name, room_alias):
	var err = yield(mp.create_room(room_name, room_alias), "completed")
#	var err = yield(mp, "create_room_completed")
	if err.has("error"):
		popup.find_node("CreateRoom").status_label.text = err["error"]
		return
	else:
		print(JSON.print(err, "\t"))
		popup.find_node("CreateRoom").hide()
		mp.sync_events()

	# Get joined rooms activates list automatically.
#	mp.get_joined_rooms()
	


# Sends a message to the given room
func _on_SendMessage_pressed() -> void:
	_send_message()


func _send_message() -> void:
	if chat_line.text.empty():
		return
	elif chat_line.text.begins_with(" "):
		return
	mp.send_message(current_room, input_text)
	chat_line.clear()


func _on_Timer_timeout():
	if current_room.empty():
		return
	elif previous_batch == next_batch:
		return
	
	var new_message = yield(mp.get_messages(current_room, previous_batch, next_batch, "b", 1, ""), "completed")
	_update_chat_window(new_message)


# Updates the input text from the LineEdit in chat section
func _on_LineEdit_text_changed(new_text):
	input_text = new_text


# Updates which room we act upon via the left sidebar
func _on_room_list_item_selected(index):
	chat_window.clear()
	current_room = joined_rooms.keys()[index]
	channel_name.text = room_list.get_item_text(index)
	var messages = yield(mp.get_messages(current_room, next_batch, "", "b", 100, ""), "completed")
	_update_chat_window(messages)


# Synchronizes data in client with server.
func _sync_to_server(sync_data : Dictionary) -> void:
	synced_data = sync_data
	joined_rooms = sync_data["rooms"]["join"]
	_update_room_list(synced_data)
	$LoginScreen.hide()


# Add rooms to our room list in the left navbar
# TODO : This seems like it should store all the synced 
#	data to a local database rather than present it directly.
func _update_room_list(rooms) -> void:
#	room_list.clear()
	var room_names = yield(_get_room_names(rooms), "completed")
	for room_name in room_names:
		if not room_name.empty():
			room_list.add_item(room_name)
		else:
			room_list.add_item("THIS NAME IS EMPTY!")


# Massive function to translate room_id into human-readable names.
func _get_room_names(rooms : Dictionary) -> Array:
	var room_number := 0	# For unresolved rooms.
	var response : Dictionary
	var room_id_array := []
	var room_names := []
	var types = [
		"m.room.name",
		"m.room.canonical_alias",
		"m.room.member"
		]
	
	if not rooms.has("joined_rooms"):
		room_id_array += synced_data["rooms"]["join"].keys()
		room_id_array += synced_data["rooms"]["invite"].keys()
		room_id_array += synced_data["rooms"]["leave"].keys()
	else:
		room_id_array += rooms["joined_rooms"]
	
	# Uses get message instead:
	for room_id in room_id_array:
		var room_name := ""
		var room_alias := ""
		var room_member_name := ""
		for type in types:
			response = yield(mp.get_messages(room_id, "s0_0_0", "", "f", 10, '{"types":["%s"]}'% type), "completed")
			if not response["chunk"].empty():
				match(type):
					"m.room.name":
						# Name
						if not response["chunk"].back()["content"]["name"].empty():
							room_name = response["chunk"].back()["content"]["name"]
							break
					"m.room.canonical_alias":
						# Alias name
						if response["chunk"].back()["content"].has("alias"):
							room_alias = response["chunk"].back()["content"]["alias"]
							break
					"m.room.member":
						# Name from members (not user self).
						if response["chunk"].back()["content"].has("displayname"):
							if not response["chunk"].back()["content"]["displayname"] == user_username:
								room_member_name = response["chunk"].back()["content"]["displayname"]
								break
							elif response["chunk"].back()["content"].has("room_alias_name"):
								room_member_name = response["chunk"].back()["content"]["room_alias_name"]
								break
					_:
						push_error("Unhandled chunk type: %s" % response["chunk"])
						print(JSON.print(response["chunk"], "\t"))

		if not room_name.empty():
			room_names.append(room_name)
		elif not room_alias.empty():
			room_names.append(room_alias)
		elif not room_member_name.empty():
			room_names.append(room_member_name)
		else:
			room_number += 1
			room_names.append("Dummy name %s" % room_number)

	if room_names.size() > room_id_array.size():
		push_error("room_names room_id_array mismatch. expected: %s, got: %s" %[room_id_array.size(), room_names.size()])
	
	return room_names


# OS notification when we recieve a message and not in focus on screen
func _notify_user() -> void:
	OS.request_attention()


# Triggers when a login call has completed.
func _on_login_completed(success):
	if success.has("error"):
		login_status.text = "Login error: %s" % success["error"]
	elif not success.has("error"):
		login_status.text = "Login success!"
		mp.sync_events()
		$Timer.start()
	else:
		login_status.text = "Unkown error occured!"
		push_error("Unknown login error!")


# Updates the chat window when we click on a room in the left sidebar.
func _update_chat_window(messages : Dictionary) -> void:
	if messages.has("chunk"):
		messages["chunk"].invert()
		for chunk in messages["chunk"]:
			_format_chat(chunk)
	next_batch = messages["start"]


# Formats the received content block for display.
func _format_chat(chunk : Dictionary) -> void:
	chat_window.add_message(chunk["type"], chunk)


func _input(event):
	if event.is_action_pressed("Enter"):
		_send_message()


func _ready():
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)
	
	var _sync_err = mp.connect("sync_completed", self, "_sync_to_server")
#	var _room_create_err = mp.connect("create_room_completed", self, "update_chat_list")
	var _login_err = mp.connect("login_completed", self, "_on_login_completed")
	var _get_joined_rooms_err = mp.connect("get_joined_rooms_completed", self, "_update_room_list")
#	var _get_room_id_by_alias_err = mp.connect("get_room_id_by_alias_completed", self, "_update_room_list")
#	var _get_room_aliases_err = mp.connect("get_room_aliases_completed", self, "_update_room_list")
#	var _get_messages_err = mp.connect("get_messages_completed", self, "_update_chat_window")
#	var _get_state_by_room_id_err = mp.connect("get_state_by_room_id_completed", self, "_update_room_list")
#	var _get_name_by_room_id_err = mp.connect("get_room_name_by_room_id_completed", self, "_update_room_list")

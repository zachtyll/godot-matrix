extends Control

const matrix_protocol = preload( "Matrix.gd" )

export(String) var user_username
export(String) var user_password

#var access_token := ""
var login := false
var mp : MatrixProtocol
var room_counter := 0
var joined_rooms := {}
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
	$LoginScreen.show()


# Register a new user.
# TODO : Figure out how to register a user
# TODO : Implement registration.
func _on_Register_pressed():
	mp.register()
	login_status.text = "Sorry, registration is not implemented!"


func _on_Settings_pressed():
	modal.show()
	modal.find_node("Settings").appear()


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


# Allows the user to join a room.
func _on_Button3_pressed():
	mp.join_room(input_text)


func _on_Timer_timeout():
	if current_room.empty():
		return
	elif previous_batch == next_batch:
		return
	
	mp.get_messages(current_room, previous_batch, next_batch, "b", 1, "")


# Updates the input text from the LineEdit in chat section
func _on_LineEdit_text_changed(new_text):
	input_text = new_text


# Login and logout
func _on_Button_toggled(button_pressed):
	if button_pressed:
		mp.login(user_username, user_password)
	else:
		$Timer.stop()
		mp.logout()
		joined_rooms.clear()
		room_list.clear()
		room_counter = 0
		chat_window.clear()


# Updates which room we act upon via the left sidebar
func _on_room_list_item_selected(index):
	chat_window.clear()
	current_room = joined_rooms.keys()[index]
	channel_name.text = room_list.get_item_text(index)
#	room_id : String,
#	from : String = next_batch,
#	to : String = "",
#	dir : String = "b",
#	limit : int = 10,
#	filter : String = ""
	mp.get_messages(current_room, next_batch, "", "b", 100, "")


# Synchronizes data in client with server.
func _sync_to_server(sync_data : Dictionary) -> void:
	joined_rooms = sync_data.get("rooms").get("join")
	_update_room_list()
	$LoginScreen.hide()
#	print(
#		JSON.print(sync_data.get("rooms").get("join").get(sync_data.get("rooms").get("join").keys()[0]).get("state"), "\t")
#		)


# Add rooms to our room list in the left navbar
# TODO : Make room naming according to Spec §13.1.1(ish)
# TODO : Make this also inlude "leave" and "invite" rooms.
# NOTE : Might want to make it so that all rooms are added
#	at once and not for each.
func _update_room_list() -> void:
	var response : Dictionary
	for room_id in joined_rooms:
		mp.get_room_name_by_room_id(room_id)
		response = yield(mp, "get_room_name_by_room_id_completed")
		if not response.has("name"):
			room_list.add_item("TODO: Canonical Alias")
		else:
			room_list.add_item(response.get("name"))
	

# OS notification when we recieve a message and not in focus on screen
func _notify_user() -> void:
	OS.request_attention()


# Triggers when a login call has completed.
func _on_login_completed(success):
	if success.has("error"):
		# TODO : Make a popup window instead of a print.
		print(JSON.print(success.get("error"), "\t"))
		login_status.text = "Login error: %s" % success.get("error")
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
		messages.get("chunk").invert()
		for chunk in messages.get("chunk"):
			_format_chat(chunk)
	next_batch = messages.get("start")


# Formats the received content block for display.
func _format_chat(chunk : Dictionary) -> void:
	chat_window.add_message(chunk.get("type"), chunk)


func _input(event):
	if event.is_action_pressed("Enter"):
		_send_message()


func _ready():
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)
	
	var _sync_err = mp.connect("sync_completed", self, "_sync_to_server")
#	var _room_create_err = mp.connect("create_room_completed", self, "update_chat_list")
	var _login_err = mp.connect("login_completed", self, "_on_login_completed")
	var _get_joined_rooms_err = mp.connect("get_joined_rooms_completed", self, "_translate_room_id")
#	var _get_room_id_by_alias_err = mp.connect("get_room_id_by_alias_completed", self, "_update_room_list")
#	var _get_room_aliases_err = mp.connect("get_room_aliases_completed", self, "_update_room_list")
	var _get_messages_err = mp.connect("get_messages_completed", self, "_update_chat_window")
#	var _get_state_by_room_id_err = mp.connect("get_state_by_room_id_completed", self, "_update_room_list")
#	var _get_name_by_room_id_err = mp.connect("get_room_name_by_room_id_completed", self, "_update_room_list")




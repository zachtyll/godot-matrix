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
var current_room : Room
var next_batch := ""
var previous_batch := ""

var rooms_array := []

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
#	user_username = username.text
#	user_password = password.text
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


# Sends a message to the given room
func _on_SendMessage_pressed() -> void:
	_send_message()


func _send_message() -> void:
	if chat_line.text.empty():
		return
	elif chat_line.text.begins_with(" "):
		return
	mp.send_message(current_room.room_id, input_text)
	chat_line.clear()


func _on_Timer_timeout():
	if current_room == null:
		return
	
	var event_data = yield(mp.get_messages(current_room.room_id, previous_batch, next_batch, "b", 1, ""), "completed")
	
	if event_data.has("error"):
		print(event_data["error"])
		return

	next_batch = event_data["start"]
	var events := []
	for event in event_data["chunk"]:
		events.append(Event.new(event))
		_update_chat_window(events)


# Updates the input text from the LineEdit in chat section
func _on_LineEdit_text_changed(new_text):
	input_text = new_text


# Updates which room we act upon via the left sidebar
func _on_room_list_item_selected(index):
	chat_window.clear()
	current_room = rooms_array[index]
	channel_name.text = rooms_array[index].room_name
	topic.text = rooms_array[index].room_topic
	_update_chat_window(current_room.timeline.events)


# Synchronizes data in client with server.
func _sync_to_server(sync_data : Dictionary) -> void:
	synced_data = sync_data
	joined_rooms = sync_data["rooms"]["join"]
	for room_id in synced_data["rooms"]["join"].keys():
		var room_data = synced_data["rooms"]["join"][room_id]
		rooms_array.append(Room.new(user_username, room_id, room_data))
		
	_update_room_list()
	$LoginScreen.hide()


# Add rooms to our room list in the left navbar
# TODO : This seems like it should store all the synced 
#	data to a local database rather than present it directly.
func _update_room_list() -> void:
	room_list.clear()
	for room in rooms_array:
		room_list.add_item(room.room_name)


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
func _update_chat_window(events : Array) -> void:
#	if messages.has("chunk"):
#		messages["chunk"].invert()
	for event in events:
		_format_chat(event)
#	next_batch = messages["start"]


# Formats the received content block for display.
func _format_chat(event : Event) -> void:
	chat_window.add_message(event)


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

extends Control

export(String) var user_username
export(String) var user_password

var input_text := ""

onready var channel_name := $MainScreen/Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/ChannelName
onready var topic := $MainScreen/Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/Topic
onready var room_list := $MainScreen/Screen/LeftSection/ItemList
onready var chat_line := $MainScreen/Screen/MidSection/ChatInput/ChatLineStretcher/ChatLine
onready var chat_window := $MainScreen/Screen/MidSection/ChatWindow
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
	GodotMatrix.login(user_username, user_password)
	username.clear()
	password.clear()
	login_status.text = "Attempting login..."


# Triggers when a login call has completed.
func _on_login(response : String):
	if not response.empty():
		login_status.text = "Login error: %s" % response
	else:
		login_status.text = "Login success!"
		GodotMatrix.sync_to_server()
		$LoginScreen.hide()


# Logout
func _on_Settings_logout():
	modal.get_node("Settings").disappear()
	GodotMatrix.logout()
	login_status.text = "Logged out."
	$LoginScreen.show()


# Register a new user.
# TODO : Figure out how to register a user
# TODO : Implement registration.
func _on_Register_pressed():
	GodotMatrix.register()
	login_status.text = "Sorry, registration is not implemented!"


func _on_create_room(response : String) -> void:
	popup.find_node("CreateRoom").status_label.text = response
	popup.find_node("CreateRoom").hide()
	modal.find_node("Settings").disappear()


func _on_Settings_pressed():
	modal.find_node("Settings").appear()


# Sends a message to the given room
func _on_SendMessage_pressed() -> void:
	_send_message()


# Necessary for being able to send via buttons and keypress.
func _send_message() -> void:
	var err := GodotMatrix.send_message(input_text)
	if err:
		push_error("Send message failed.")
	chat_line.clear()


# Updates the input text from the LineEdit in chat section
func _on_LineEdit_text_changed(new_text):
	input_text = new_text


# Updates which room we act upon via the left sidebar
func _on_room_list_item_selected(index):
	chat_window.clear()
	GodotMatrix.set_current_room(index)
	channel_name.text = GodotMatrix.get_room(index).room_name
	topic.text = GodotMatrix.get_room(index).room_topic
	_update_chat_window(GodotMatrix.get_room_events(index))


func _on_Settings_close_settings():
	pass # Replace with function body.


# Display create room popup.
func _on_Settings_create_room():
	popup.find_node("CreateRoom").popup_centered()


# Add rooms to our room list in the left navbar
# TODO : This seems like it should store all the synced 
#	data to a local database rather than present it directly.
func _update_room_list(rooms : Array) -> void:
	room_list.clear()
	for room in rooms:
		room_list.add_item(room.room_name)


# Updates the chat window when we click on a room in the left sidebar.
func _update_chat_window(events : Array) -> void:
	for event in events:
		chat_window.add_message(event)


func _input(event):
	if event.is_action_pressed("Enter"):
		_send_message()


func _ready():
	var _login_err := GodotMatrix.connect("login", self, "_on_login")
	var _rooms_joined_err := GodotMatrix.connect("rooms_joined", self, "_update_room_list")
	var _refresh_err := GodotMatrix.connect("incoming_events", self, "_update_chat_window")
	var _create_room_err := GodotMatrix.connect("create_room", self, "_on_create_room")

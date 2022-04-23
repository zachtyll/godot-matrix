extends Control

export(String) var user_username
export(String) var user_password

var input_text := ""

onready var channel_name := $MainScreen/Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/ChannelName
onready var topic := $MainScreen/Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/Topic
onready var room_list := $MainScreen/Screen/LeftSection/RoomList
onready var chat_line := $MainScreen/Screen/MidSection/ChatInput/ChatLineStretcher/ChatLine
onready var chat_window := $MainScreen/Screen/MidSection/ChatWindow
onready var chat_history_list := null
onready var login_status := $LoginScreen/CenterContainer/VBoxContainer/LoginStatus
onready var username := $LoginScreen/CenterContainer/VBoxContainer/GridContainer/Username
onready var password := $LoginScreen/CenterContainer/VBoxContainer/GridContainer/Password
onready var modal := $Modal
onready var popup := $PopUps
onready var sprite := $MainScreen/Screen/RightSection/Sprite


func _on_Preview_pressed():
	var response = yield(GodotMatrix.preview_url("https://stackoverflow.com/questions/3770630/c-detect-whether-a-file-is-png-or-jpeg"), "completed")
	if response.has("error"):
		print(response["error"])
		return
	var texture = yield(GodotMatrix.thumbnail(response["og:image"]), "completed")
	sprite.texture = texture


func _on_Thumbnail_pressed():
	var m_uri := "mxc://matrix.org/asYJxRRVUMCJYvKaMQEEjWsZ"
	var response = yield(GodotMatrix.thumbnail(m_uri), "completed")
	if response is Dictionary:
		print(response.error)
	else:
		sprite.texture = response


func _on_Download_pressed():
	var m_uri := "mxc://matrix.org/2022-04-23_ZFCUGJXNDSEcuZIS"
	var response = yield(GodotMatrix.download(m_uri), "completed")
	if response is Dictionary:
		print(response.error)
	else:
		sprite.texture = response


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
	GodotMatrix.logout()


func _on_logout(error : int) -> void:
	if error:
		return
	else:
		chat_window.clear()
		chat_line.clear()
		room_list.clear()
		modal.get_node("Settings").disappear()
		login_status.text = "Logged out."
		$LoginScreen.show()


# Register a new user.
# TODO : Figure out how to register a user
# TODO : Implement registration.
func _on_Register_pressed():
	GodotMatrix.register()
	login_status.text = "Sorry, registration is not implemented!"


# Call when successfully creating a room from GodotMatrix.
func _on_create_room(error : int) -> void:
	if error:
		popup.find_node("CreateRoom").status_label.text = "Failed!"
	else:
		popup.find_node("CreateRoom").status_label.text = "Success!"
		popup.find_node("CreateRoom").hide()
		modal.find_node("Settings").disappear()


func _on_Settings_pressed():
	modal.find_node("Settings").appear()


# Sends a message to the given room
func _on_SendMessage_pressed() -> void:
	_send_message()


# Updates the input text from the LineEdit in chat section
func _on_ChatLine_text_changed(new_text):
	input_text = new_text


# Send a message when enter is hit and ChatLine is in focus.
func _on_ChatLine_text_entered(_new_text):
	_send_message()


# Search bar.
func _on_LineEdit_text_changed(new_text):
	GodotMatrix.search_user(new_text)


# Updates which room we act upon via the left sidebar
func _on_RoomList_room_selected(room : Room):
	chat_window.clear()
	GodotMatrix.set_current_room(room)
	channel_name.text = room.display_name()
	topic.text = room.topic()
	_update_chat_window(room.timeline().events())


func _on_Settings_close_settings():
	pass # Replace with function body.


# Display create room popup.
func _on_Settings_create_room():
	popup.find_node("CreateRoom").popup_centered()


# Necessary for being able to send via buttons and keypress.
func _send_message() -> void:
	if chat_line.text.empty():
		return
	var err := GodotMatrix.send_message(input_text)
	if err:
		print("Send message failed.")
	chat_line.clear()


# Add rooms to our room list in the left navbar
func _update_room_list(rooms : Array) -> void:
	room_list.clear()
	for room in rooms:
		room_list.add_room(room)


# Updates the chat window when we click on a room in the left sidebar.
func _update_chat_window(events : Array) -> void:
	for event in events:
		chat_window.add_message(event)


func _ready():
	var _login_err := GodotMatrix.connect("login", self, "_on_login")
	var _rooms_joined_err := GodotMatrix.connect("rooms_joined", self, "_update_room_list")
	var _refresh_err := GodotMatrix.connect("incoming_events", self, "_update_chat_window")
	var _create_room_err := GodotMatrix.connect("create_room", self, "_on_create_room")
	var _logout_err := GodotMatrix.connect("logout", self, "_on_logout")


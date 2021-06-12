extends Control

const matrix_protocol = preload( "Matrix.gd" )

export(String) var user_username
export(String) var user_password

#var access_token := ""
var login := false
var input_text := ""
var mp : MatrixProtocol
var room_counter := 0
var joined_rooms := []
var current_room = ""
var next_batch := ""
var previous_batch := ""

onready var channel_name := $Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/ChannelName
onready var topic := $Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/Topic
onready var room_list := $Screen/LeftSection/ItemList
onready var chat_line := $Screen/MidSection/ChatInput/ChatLineStretcher/ChatLine
onready var chat_window := $Screen/MidSection/ChatWindow
onready var chat_history_list := null


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


# Register a new user.
# TODO : Figure out how to register a user
# TODO : Implement registration.
func _on_Button4_pressed():
	mp.register()


# Sync all events. Should only be used on startup.
# TODO : Use only sync on startup.
func _on_Button5_pressed():
#	var url := 'https://matrix.org/_matrix/client/r0/sync?filter={"room":{"timeline":{"limit":10}}}&since=s9_13_0_1_1&access_token=' + str(access_token)
	mp.sync_events("filter={'room':{'timeline':{'limit':10}}}", next_batch)


# Legacy content getter.
# TODO : Make this sync only on startup and filter less data.
func update_list(response) -> void:
#	chat_window.add_message("", response)
	
	print(JSON.print(response, "\t"))

#	chat_history_list.add_item(JSON.print(response, "\t"))
#	if not response.has("next_batch"):
#		return
#	previous_batch = next_batch
#	# Set next message batch to be expected
#	next_batch = response.get("next_batch")
#	# Ugly algo to get message text only
#	var rooms = response["rooms"].get("join").keys()
#	var event_array = []
#	for key in rooms:
#		# TODO : Refactor this algo.
#		event_array.append(response["rooms"].get("join").get(key).get("timeline").get("events"))
#		var something = response["rooms"].get("join").get(key).get("timeline").get("events")
#		for i in something.size():
#			if something[i].get("content").get("body") is String:
#				chat_history_list.add_item(something[i].get("content").get("body"))


# Add rooms to our room list in the left navbar
# TODO : Make room naming according to Spec §13.1.1(ish)
func _update_room_list(room_name : Dictionary) -> void:
	if not room_name.has("name"):
		return
	room_list.add_item(room_name.get("name"))


# Translates room id into a human-readable alias.
# TODO : Make it work the way it should according to spec.
# TODO : Make this work with room_alias_by_id instead
# 	of using the hacky way of finding canonical alias.
func _translate_room_id(rooms : Dictionary):
	var test
	for room_id in rooms["joined_rooms"]:
		joined_rooms.append(room_id)
		mp.get_room_name_by_room_id(room_id)
		
		test = yield(mp, "get_room_name_by_room_id_completed")
		print("Test is: %s" % test)
		print(JSON.print(test, "\t"))



# OS notification when we recieve a message and not in focus on screen
func _notify_user() -> void:
	OS.request_attention()


# Triggers when a login call has completed.
func _on_login_completed(success):
	if success.has("error"):
		# TODO : Make a popup window instead of a print.
		print(JSON.print(success.get("error"), "\t"))
	elif not success.has("error"):
		mp.sync_events()
		$Timer.start()
	else:
		push_error("Unknown login error!")


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
	current_room = joined_rooms[index]
	channel_name.text = room_list.get_item_text(index)
#	room_id : String,
#	from : String = next_batch,
#	to : String = "",
#	dir : String = "b",
#	limit : int = 10,
#	filter : String = ""
#	mp.get_messages(current_room, next_batch, "", "b", 10, "")
	mp.get_messages(current_room, next_batch, "", "b", 100, "")


# Updates the chat window when we click on a room in the left sidebar.
func _update_chat_window(messages : Dictionary) -> void:
	if messages.has("chunk"):
		messages.get("chunk").invert()
		for content in messages.get("chunk"):
			_format_chat(content)
	next_batch = messages.get("start")


# Formats the received content block for display.
func _format_chat(content : Dictionary) -> void:
	chat_window.add_message(content.get("type"), content)


func _input(event):
	if event.is_action_pressed("Enter"):
		_send_message()


func _on_Timer_timeout():
	if current_room.empty():
		return
	elif previous_batch == next_batch:
		return
	
	mp.get_messages(current_room, previous_batch, next_batch, "b", 1, "")


func _ready():
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)
	var _sync_err = mp.connect("sync_completed", self, "update_list")
#	var _room_create_err = mp.connect("create_room_completed", self, "update_chat_list")
	var _login_err = mp.connect("login_completed", self, "_on_login_completed")
	var _get_joined_rooms_err = mp.connect("get_joined_rooms_completed", self, "_translate_room_id")
#	var _get_room_id_by_alias_err = mp.connect("get_room_id_by_alias_completed", self, "_update_room_list")
#	var _get_room_aliases_err = mp.connect("get_room_aliases_completed", self, "_update_room_list")
	var _get_messages_err = mp.connect("get_messages_completed", self, "_update_chat_window")
#	var _get_state_by_room_id_err = mp.connect("get_state_by_room_id_completed", self, "_update_room_list")
	var _get_name_by_room_id_err = mp.connect("get_room_name_by_room_id_completed", self, "_update_room_list")

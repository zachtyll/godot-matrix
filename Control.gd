extends Control

const matrix_protocol = preload( "Matrix.gd" )

export(String) var user_username
export(String) var user_password

var access_token = ""
var login : bool = false
var input_text := ""
var mp : MatrixProtocol
var room_counter := 0
var joined_rooms := []
var current_room = ""
var next_batch := ""

onready var channel_name := $Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/ChannelName
onready var topic := $Screen/MidSection/TopBarMid/TopBarMidHbox/ChannelLabels/Topic
onready var chat_history_list := $Screen/MidSection/ItemList
onready var room_list := $Screen/LeftSection/ItemList
onready var chat_line := $Screen/MidSection/ChatInput/LineEdit


# Sends a message to the given room
func _on_Button2_pressed() -> void:
	if input_text.empty():
		return
	_send_message()


func _send_message() -> void:
	if chat_line.text.empty():
		return
	elif chat_line.text.begins_with(" "):
		return
	mp.send_message(current_room, input_text)
	chat_line.clear()
	# We need to yield here, so that we catch the newly sent message.
	yield(mp, "send_message_completed")
	mp.get_messages(current_room, next_batch, "", "b", 1, "")


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
	if not response.has("next_batch"):
		return
	# Set next message batch to be expected
	next_batch = response.get("next_batch")
	# Ugly algo to get message text only
	var rooms = response["rooms"].get("join").keys()
	var event_array = []
	for key in rooms:
		# TODO : Refactor this algo.
		event_array.append(response["rooms"].get("join").get(key).get("timeline").get("events"))
		var something = response["rooms"].get("join").get(key).get("timeline").get("events")
		for i in something.size():
			if something[i].get("content").get("body") is String:
				chat_history_list.add_item(something[i].get("content").get("body"))


# Add rooms to our room list in the left navbar
# TODO : Currently broken due to "Unrecognized request" in "room_aliases".
func _update_room_list(room_name : Dictionary) -> void:
	if not room_name.has("name"):
		return	
	room_list.add_item(room_name.get("name"))


# Translates room id into a human-readable alias.
# TODO : Make it work the way it should according to spec.
# TODO : Make this work with room_alias_by_id instead
# 	of using the hacky way of finding canonical alias.
func _translate_room_id(rooms : Dictionary):
	for room_id in rooms["joined_rooms"]:
		joined_rooms.append(room_id)
		mp.get_room_name_by_room_id(room_id)



# OS notification when we recieve a message and not in focus on screen
func _notify_user() -> void:
	OS.request_attention()


# Triggers when a login call has completed.
func _on_login_completed(success):
	if success:
		mp.get_joined_rooms()
		mp.sync_events('filter={"room":{"timeline":{"limit":10}}}', next_batch)
	elif not success:
		print("Invalid login!")
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
		mp.logout()
		room_list.clear()
		room_counter = 0
		chat_history_list.clear()


# Updates which room we act upon via the left sidebar
# TODO : Fix so that we can see old and new messages at the same time.
func _on_room_list_item_selected(index):
	chat_history_list.clear()
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


# Updates the chat window when we click on a room in the left sidebar
func _update_chat_window(messages : Dictionary) -> void:
	if messages.has("chunk"):
		messages.get("chunk").invert()
		for content in messages.get("chunk"):
			chat_history_list.add_item(_format_chat(content))


func _format_chat(content) -> String:
	var message_line := ""
	if not content == null:
		match(content.get("type")):
			"m.room.message":
				match(content.get("content").get("msgtype")):
					"m.text":
						message_line += content.get("sender") + ": "
						message_line += content.get("content").get("body")
					_:
						print("Can only handle text right now!")
						print("This is a: " + str(content.get("msgtype")))
			"m.room.guest_access":
				if content.get("content").has("guest_access"):
					message_line += "Guest access set to: "
					message_line += content.get("content").get("guest_access")
				else:
					print("Unexpected content block:")
					print(content.get("content"))
			"m.room.member":
				if content.get("content").has("room_alias_name"):
					channel_name.text = content.get("content").get("room_alias_name")
					
					message_line += content.get("content").get("displayname")
					message_line += " "
					message_line += content.get("content").get("membership")
					message_line += " "
					message_line += content.get("content").get("room_alias_name")
				
			"m.room.create":
				print("TODO : Implement m.room.create")
				print(content.get("content"))
			"m.room.history_visibility":
				print("TODO : Implement m.room.history_visibility")
				print(content.get("content"))
				message_line += "Message history set to: "
				message_line += content.get("content").get("history_visibility")
			"m.room.join_rules":
				# TODO : Fix the formatting to be like natural language.
				message_line += "Join rule set to: "
				message_line += content.get("content").get("join_rule")
			"m.room.canonical_alias":
				print("TODO : Implement m.room.canonical_alias")
				print(content.get("content"))
			"m.room.topic":
				print("TODO : Implement m.room.topic")
				if content.get("content").has("topic"):
					topic.text = content.get("content").get("topic")
					message_line += "The topic was set to: "
					message_line += content.get("content").get("topic")
			"m.room.name":
				print("TODO : Implement m.room.name")
				print(content.get("content"))
			"m.room.power_levels":
				print("TODO : Implement m.room.power_levels")
				print(content.get("content"))
			"m.room.encryption":
				# TODO : Figure out wether this statement is actually
				#	completely true.
				message_line += "Messages are encrypted with "
				message_line += content.get("content").get("algorithm")
			"m.room.encrypted":
				# TODO : Figure out how to solve decryption.
				#	Maybe this shouldn't even be decrypted?
				#	Spec is a little unclear.
				message_line += "This message is encrypted."
			"m.reaction":
				print("TODO : Implement m.reation")
				print(content.get("content"))
			"m.room.redaction":
				print("TODO : Implement m.redaction")
				print(content.get("content"))
			_:
				push_warning("Unhandled message in content block: " + str(content.get("type")))
	return message_line


func _input(event):
	if event.is_action_pressed("Enter"):
		_send_message()


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

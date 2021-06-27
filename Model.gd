class_name GodotMatrix
extends Node

const matrix_protocol = preload("Matrix.gd")


#var access_token := ""
#var login := false
var mp : MatrixProtocol
var room_counter := 0
var joined_rooms := {}
var synced_data := {}
var input_text := ""
var current_room : Room
var next_batch := ""
var previous_batch := ""
var chat_line := "" setget set_chat_line
var user_username

var rooms_array := []


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
#		_update_chat_window(events)


func login(username : String, password : String) -> bool:
	var result = yield(mp.login(username, password), "completed")
	if result.has("error"):
		return false
	else:
		# TODO : Temporary.
		user_username = username
		return true
	
	
#	if success.has("error"):
#		login_status.text = "Login error: %s" % success["error"]
#	elif not success.has("error"):
#		login_status.text = "Login success!"
#		mp.sync_events()
#		$Timer.start()
#	else:
#		login_status.text = "Unkown error occured!"
#		push_error("Unknown login error!")


func logout() -> bool:
	var result = yield(mp.logout(), "completed")
	if result.has("error"):
		return false
	else:
		joined_rooms.clear()
#		room_list.clear()
		room_counter = 0
#		chat_window.clear()
		return true


func register() -> void:
	mp.register()


func _send_message() -> void:
	if chat_line.empty():
		return
	elif chat_line.begins_with(" "):
		return
	mp.send_message(current_room.room_id, input_text)
	chat_line = ""


func set_chat_line(new_text : String) -> void:
	input_text = new_text


func get_room(index : int) -> Room:
#	chat_window.clear()
	current_room = rooms_array[index]
#	channel_name.text = rooms_array[index].room_name
#	topic.text = rooms_array[index].room_topic
#	_update_chat_window(current_room.timeline.events)
	return current_room


# Synchronizes data in client with server.
func _sync_to_server(sync_data : Dictionary) -> void:
	synced_data = sync_data
	joined_rooms = sync_data["rooms"]["join"]
	for room_id in synced_data["rooms"]["join"].keys():
		var room_data = synced_data["rooms"]["join"][room_id]
		rooms_array.append(Room.new(user_username, room_id, room_data))
		
#	_update_room_list()
	$LoginScreen.hide()


# Add rooms to our room list in the left navbar
# TODO : This seems like it should store all the synced 
#	data to a local database rather than present it directly.
func _update_room_list() -> void:
	pass
#	room_list.clear()
#	for room in rooms_array:
#		room_list.add_item(room.room_name)


# OS notification when we recieve a message and not in focus on screen
func _notify_user() -> void:
	OS.request_attention()


# Updates the chat window when we click on a room in the left sidebar.
func _update_chat_window(events : Array) -> void:
	for event in events:
		_format_chat(event)


# Formats the received content block for display.
func _format_chat(event : Event) -> void:
#	chat_window.add_message(event)
	pass


func _ready():
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)
	
	var _sync_err = mp.connect("sync_completed", self, "_sync_to_server")
	var _login_err = mp.connect("login_completed", self, "_on_login_completed")
	var _get_joined_rooms_err = mp.connect("get_joined_rooms_completed", self, "_update_room_list")

extends Node

const MEDIA_ID_LENGTH = 17
const matrix_protocol = preload("Matrix.gd")


var mp : MatrixProtocol
var current_room : Room setget set_current_room
var input_text := ""
var next_batch := "" setget set_next_batch
var previous_batch := ""
var text_input := "" setget set_text_input
var user_username := ""
var user_password := ""

var rooms_array := []

onready var timer = Timer.new()

signal rooms_joined
signal login
signal logout
signal incoming_events
signal create_room
#signal synchronize
#signal room_leave
signal room_invite
#signal room_join
#signal reaction
#signal message


func preview_url(url : String):
	var test = yield(mp.preview_url(url),  "completed")
	return test


func thumbnail(media_id : String, min_width : int = 32, min_height : int = 32):
	if media_id == null:
		return
	
	var image = Image.new()
	var texture = ImageTexture.new()
	var thumbnail = yield(mp.get_thumbnail(media_id.right(MEDIA_ID_LENGTH), min_width, min_height),  "completed")

	if thumbnail is Dictionary:
		return null
	else:
		var image_error = image.load_png_from_buffer(thumbnail)
		if image_error:
			print("An error occurred while trying to display the image.")
		texture.create_from_image(image)
	
	return texture


func download():
	var data = yield(mp.download("CkjpviDvtacypZqLsxkpPxJm"),  "completed")
	var image = Image.new()
	var image_error = image.load_jpg_from_buffer(data)
	if image_error:
		print("An error occurred while trying to display the image.")
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	return texture

func _on_refresh_messages():
	if current_room == null:
		return

	var event_data = yield(mp.get_messages(current_room.room_id, previous_batch, next_batch, "b", 1, ""), "completed")

	if event_data.has("error"):
		var error_string := "{errcode}: {error}".format(event_data)
		push_error(error_string)
		return

	next_batch = event_data["start"]
	var events := []
	for event in event_data["chunk"]:
		events.append(Event.new(event))
	emit_signal("incoming_events", events)


func login(username : String, password : String) -> int:
	var result = yield(mp.login(username, password), "completed")
	if result.has("error"):
		var error_string := "{errcode}: {error}".format(result)
		push_error(error_string)
		emit_signal("login", result["error"])
		return FAILED
	else:
		emit_signal("login", "")
		user_username = username
		timer.start()
		return OK


func logout() -> void:
	var logout = yield(mp.logout(), "completed")
	if logout:
		timer.stop()
		rooms_array.clear()
		emit_signal("logout", OK)
	else:
		emit_signal("logout", FAILED)
		var error_string := "Logout: " + str(logout)
		push_error(error_string)


func register() -> void:
	mp.register()


# Call for room creation.
func room_create(room_alias : String, room_name : String) -> void:
	var result = yield(mp.create_room(
		MatrixProtocol.RoomVisibility.PRIVATE,
		room_alias,
		room_name
		), "completed")
	if result.has("error"):
		emit_signal("create_room", FAILED)
		var error_string := "{errcode}: {error}".format(result)
		push_error(error_string)
	else:
		emit_signal("create_room", OK)
		sync_to_server()


# Invite to room by user ID.
func room_invite(room_id : String, user : String) -> int:
	var result = yield(mp.invite(room_id, user), "completed")
	if result.has("error"):
		return FAILED
	else:
		emit_signal("room_invite", result)
		return OK


# TODO : Tombstone?
func room_delete(_room_id : String) -> void:
	pass


func room_join(room_id : String) -> int:
	var result = yield(mp.room_join(room_id), "completed")
	if result.has("error"):
		return FAILED
	else:
		return OK


func room_ban(room_id : String, user_id : String, reason : String = "") -> int:
	var result = yield(mp.room_ban(room_id, user_id, reason), "completed")
	if result.has("error"):
		return FAILED
	else:
		return OK


func room_forget(room_id : String) -> int:
	var result = yield(mp.room_forget(room_id), "completed")
	if result.has("error"):
		return FAILED
	else:
		return OK


func room_kick(room_id : String, user_id : String, reason : String = "") -> int:
	var result = yield(mp.room_kick(room_id, user_id, reason), "completed")
	if result.has("error"):
		return FAILED
	else:
		return OK


func room_leave(room_id : String) -> int:
	var result = yield(mp.room_leave(room_id), "completed")
	if result.has("error"):
		return FAILED
	else:
		return OK


func room_unban(room_id : String, user_id : String) -> int:
	var result = yield(mp.room_unban(room_id, user_id), "completed")
	if result.has("error"):
		return FAILED
	else:
		return OK


func message_redact(room_id : String, event_id : String, transaction_id : String, reason : String = "") -> int:
	var result = yield(mp.message_redact(room_id, event_id, transaction_id, reason), "completed")
	if result.has("error"):
		return FAILED
	else:
		return OK


func search_user(search_term : String, limit : int = 10):
	var result = yield(mp.search_user(search_term, limit), "completed")
	if result.has("error"):
		return FAILED
	else:
		print(JSON.print(result, "\t"))
		return OK


# Not found in spec.
func append_reaction(_event_id : String, _reaction) -> void:
	pass


func send_message(message_text : String) -> int:
	if current_room == null:
		return FAILED
	elif message_text.empty():
		return FAILED
	elif message_text.begins_with(" "):
		return FAILED
	else:
		mp.send_message(current_room.room_id, message_text)
		return OK


func set_next_batch(new_batch) -> void:
	previous_batch = next_batch
	next_batch = new_batch


func set_text_input(new_text : String) -> void:
	input_text = new_text


func set_current_room(new_room : Room) -> void:
	current_room = new_room


func get_room(index : int) -> Room:
	return rooms_array[index]


func get_room_events(index : int) -> Array:
	return rooms_array[index].timeline.events


# Synchronizes data in client with server.
func sync_to_server() -> void:
	var sync_data = yield(mp.sync_events(), "completed")
	for room_id in sync_data["rooms"]["join"].keys():
		var room_data = sync_data["rooms"]["join"][room_id]
		rooms_array.append(Room.new(user_username, room_id, room_data))
		# Always gets the last created room.
		rooms_array.back().room_membership = Room.RoomMembership.JOIN
	rooms_array.sort()
	emit_signal("rooms_joined", rooms_array)


# OS notification when we recieve a message and not in focus on screen
func _notify_user() -> void:
	OS.request_attention()


func _ready():
	timer.wait_time = 3
	self.add_child(timer)
	timer.connect("timeout", self, "_on_refresh_messages")
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)

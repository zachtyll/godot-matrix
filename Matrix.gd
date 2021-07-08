class_name MatrixProtocol
extends Node

enum Preset {
	PRIVATE_CHAT,
	PUBLIC_CHAT,
	TRUSTED_PRIVATE_CHAT
}

enum RoomVisibility {
	PUBLIC,
	PRIVATE
}

# m.room.create content-field
#	used in creating rooms.
class CreationContent:
	var data : Dictionary


	func _init(
		new_creator : String = "",
		new_federate : bool = true,
		new_room_version : String = "1",
		new_predecessor : PreviousRoom = PreviousRoom.new()
		):
		
		data = {
			"creator" : new_creator,
			"federate" : new_federate,
			"room_version" : new_room_version,
			"predecessor" : new_predecessor.data,
		}
		
		

class PreviousRoom:
	var data : Dictionary

	func _init(new_room_id : String = "", new_event_id : String = ""):
		data = {
			"room_id" : new_room_id,
			"event_id" : new_event_id,
		}
		


class PowerLevelEventContent:
	var data : Dictionary


	func _init(
		new_ban : int = 50,
		new_events : EventPowerLevels = EventPowerLevels.new(),
		new_events_default = 0,
		new_invite : int = 50,
		new_kick : int = 50,
		new_redact : int = 50,
		new_state_default : int = 50,
		new_users : Dictionary = {},
		new_notifications : Notifications = Notifications.new(),
		new_users_default : int = 0
		
	):
		data = {
			"ban" :  new_ban,
			"events" : new_events.data,
			"events_default" : new_events_default,
			"invite" :  new_invite,
			"kick" : new_kick,
			"redact" : new_redact,
			"state_default" : new_state_default,
			"users" : new_users,
			"users_default" : new_notifications.room,
			"notifications" : new_users_default,
		}


class EventPowerLevels:
	var data : Dictionary


	func _init(
		new_avatar : int = 50,
		new_canonical_alias : int = 50,
		new_encryption : int = 100,
		new_history_visibility : int = 100,
		new_room_name : int = 100,
		new_power_levels : int = 100,
		new_server_acl : int = 100,
		new_tombstone : int = 100
	):
		data = {
			"avatar" : new_avatar,
			"canonical_alias" : new_canonical_alias,
			"encryption" : new_encryption,
			"history_visibility" : new_history_visibility,
			"room_name" : new_room_name,
			"power_levels" : new_power_levels,
			"server_acl" : new_server_acl,
			"tombstone" : new_tombstone,
		}


# For future-proofing.
class Notifications:
	var room : int
	
	
	func _init(new_room : int = 50):
		room = new_room


var access_token := ""
var user_identification := ""

# Signals since it's async calls.
signal sync_completed
signal login_completed
signal logout_completed
signal invite_completed
signal room_join_completed
signal room_ban_completed
signal room_forget_completed
signal room_kick_completed
signal room_leave_completed
signal room_unban_completed
signal send_message_completed
signal get_members_completed
signal create_room_completed
signal get_joined_rooms_completed
signal get_room_id_by_alias_completed
signal get_room_aliases_completed
signal get_messages_completed
signal get_state_by_room_id_completed
signal get_room_name_by_room_id_completed
signal message_redact_completed
signal who_am_i_completed
signal search_user_completed
signal get_displayname_completed
signal download_completed
signal get_thumbnail_completed
signal preview_url_completed


# Logs a user into Matrix
# TODO : Make this work with any homeserver.
# TODO : Make this work with any type of authentication.
func login(username : String, password : String):
	var device_id := OS.get_unique_id() + "_" + username
	var url := "https://matrix.org/_matrix/client/r0/login"
	var body := {
		"identifier": {
		"type": "m.id.user",
		"user": username
		},
		"initial_device_display_name": device_id,
		"password": password,
		"type": "m.login.password"
		}
	_make_post_request(url, body, true, "_login_completed")
	var response = yield(self, "login_completed")
	return response


# Logs out a session from the server.
func logout():
	var url := "https://matrix.org/_matrix/client/r0/logout"
	var body := {}
	
	_make_post_request(url, body, true, "_logout_completed")
	var response = yield(self, "logout_completed")
	return response
	

# Registers a new user on Matrix.
# TODO : Implement registration.
# TODO : Allow for 3PID registration.
func register():
	print("Not implemented.")


# -----------Room Participation-------------- #

# Invite by Matrix user ID.
func invite(room_id : String, user_id : String) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/rooms/%s/invite" % room_id
	var body := {
		"user_id" : user_id
	}
	_make_post_request(url, body, true, "_invite_completed")
	var response = yield(self, "invite_completed")
	return response


# Joins a room that the user is invited to or a public room.
func room_join(room_id_or_alias : String, server_name : String = "matrix.org") -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/join/%s?server_name=%s" % [room_id_or_alias, server_name]
	var body := {
		# TODO : Add 3PID implementation
	}
	_make_post_request(url, body, true, "_room_join_completed")
	var response = yield(self, "room_join_completed")
	return response


func room_ban(room_id : String, user_id : String, reason : String = "", server : String = "matrix.org"):
	var url := "https://matrix.org/_matrix/client/r0/rooms/%s:%s/ban" % [room_id, server]
	var body := {
		"reason" : reason,
		"user_id" : user_id
	}
	_make_post_request(url, body, true, "_room_ban_completed")
	var response = yield(self, "room_ban_completed")
	return response


func room_forget(room_id : String, server : String = "matrix.org"):
	var url := "https://matrix.org/_matrix/client/r0/rooms/%s:%s/forget" % [room_id, server]
	var body := {}
	_make_post_request(url, body, true, "_room_forget_completed")
	var response = yield(self, "room_forget_completed")
	return response


func room_kick(room_id : String, user_id : String, reason : String = "", server : String = "matrix.org"):
	var url := "https://matrix.org/_matrix/client/r0/rooms/%s:%s/ban" % [room_id, server]
	var body := {
		"reason" : reason,
		"user_id" : user_id
	}
	_make_post_request(url, body, true, "_room_kick_completed")
	var response = yield(self, "room_kick_completed")
	return response


func room_leave(room_id : String, server : String = "matrix.org"):
	var url := "https://matrix.org/_matrix/client/r0/rooms/%s:%s/forget" % [room_id, server]
	var body := {}
	_make_post_request(url, body, true, "_room_leave_completed")
	var response = yield(self, "room_leave_completed")
	return response


func room_unban(room_id : String, user_id : String) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/rooms/%s/unban" % room_id
	var body := {
		"user_id" : user_id,
	}
	_make_post_request(url, body, true, "_room_unban_completed")
	var response = yield(self, "room_unban_completed")
	return response

# --------------------------------------------- #

# Sends a message to the server.
# NOTE : Message does not always mean "text message".
# NOTE : Returns a message ID for redactions and edits.
func send_message(room : String, message : String):
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room + "/send/m.room.message"
	var content := {
		"msgtype" : "m.text",
		"body" : message
		}
	_make_post_request(url, content, true, "_send_message_completed")
	var response = yield(self, "send_message_completed")
	return response


# Syncs client state with server state.
# NOTE : Should be used only on startup.
# NOTE : Heavy workload.
func sync_events(filter : String = (""),  since : String = "s0", full_state : bool = false , set_presence : String = "offline", timeout : int = 0) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/sync?{0}&since={1}&full_state={2}&set_presence={3}&timeout={4}".format([filter, since, (str(full_state).to_lower()), set_presence, timeout])
	_make_get_request(url, "_sync_completed")
	var response = yield(self, "sync_completed")
	return response


# Gets all members of a room.
func get_members(room : String) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room + "/joined_members"
	_make_get_request(url, "_get_members_completed")
	var response = yield(self, "get_members_completed")
	return response


# Creates a new room.
func create_room(
	visibility : int = RoomVisibility.PRIVATE,
	room_alias_name : String = "",
	room_name : String = "",
	topic : String = "",
	invite : Array = [],
	invite_3pid : Array = [],
	room_version : String = "1",
	creation_content : CreationContent = CreationContent.new(user_identification),
	initial_state : Array = [],
	preset : int = Preset.PRIVATE_CHAT,
	is_direct : bool = false,
	power_level_content_override : PowerLevelEventContent = PowerLevelEventContent.new()
	
	) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/createRoom"
	
	power_level_content_override.data["users"][user_identification] = 100
	
	var room_visibility := ""
	match(visibility):
		RoomVisibility.PRIVATE:
			room_visibility = "private"
		RoomVisibility.PUBLIC:
			room_visibility = "public"

	var room_preset := ""
	match(preset):
		Preset.PRIVATE_CHAT:
			room_preset = "private_chat"
		Preset.PUBLIC_CHAT:
			room_preset = "public_chat"
		Preset.TRUSTED_PRIVATE_CHAT:
			room_preset = "trusted_private_chat"
			
	var body := {
		"room_visibility" : room_visibility,
		"room_alias_name" : room_alias_name,
		"name": room_name,
		"topic" : topic,
		"invite" : invite,
		"invite_3pid" : invite_3pid,
		"room_version" : room_version,
		"creation_content" : creation_content.data,
		"initial_state" : initial_state,
		"preset": room_preset,
		"is_direct" : is_direct,
		"power_level_content_override" : power_level_content_override.data, # This one breaks everything.
	}
	_make_post_request(url, body, true, "_create_room_completed")
	var response = yield(self, "create_room_completed")
	return response


# Gets all rooms the user has joined.
func get_joined_rooms() -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/joined_rooms"
	_make_get_request(url, "_get_joined_rooms_completed")
	var response = yield(self, "get_joined_rooms_completed")
	return response


# Gets a room id by reading an alias.
func get_room_id_by_alias(alias : String, homeserver : String = "matrix.org") -> void:
	var url := "https://matrix.org/_matrix/client/r0/directory/room/" + alias + ":" + homeserver
	_make_get_request(url, "_get_room_id_by_alias_completed")
	var response = yield(self, "get_room_id_by_alias_completed")
	return response


# Gets an array of local aliases for a room.
# TODO : Figure out what "local" implies.
func get_room_aliases(room_id : String) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/aliases"
	_make_get_request(url, "_get_room_aliases_completed")
	var response = yield(self, "get_room_aliases_completed")
	return response


# Gets messages from room "room_id". Batch "from" to batch "to" with max "limit" messages.
# "dir" handles the direction to paginate. ("b"ackwards or "f"orwards).
# TODO : Figure out how "filter" works.
func get_messages(room_id : String, from : String = "", to : String = "", dir : String = "b", limit : int = 10, filter : String = ""):
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/messages?from=" + from + "&to=" + to + "&dir=" + dir + "&limit=" + str(limit) +  "&filter=" + filter
	_make_get_request(url, "_get_messages_completed")
	var response = yield(self, "get_messages_completed")
	return response


func get_state_by_room_id(room_id : String) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/state"
	_make_get_request(url, "_get_state_by_room_id_completed")
	var response = yield(self, "get_state_by_room_id_completed")
	return response


func get_room_name_by_room_id(room_id : String) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/state/m.room.name"
	_make_get_request(url, "_get_room_name_by_room_id_completed")
	var response = yield(self, "get_room_name_by_room_id_completed")
	return response


func message_redact(room_id : String, event_id : String, transaction_id : String, reason : String = "") -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/rooms/%s/redact/%s/%s" % [room_id, event_id, transaction_id]
	var body := {
		"reason" : reason,
	}
	_make_put_request(url, body, true, "_message_redact_completed")
	var response = yield(self, "message_redact_completed")
	return response


# Get current user_id.
func who_am_i() -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/account/whoami"
	_make_get_request(url, "_who_am_i_completed")
	var response = yield(self, "who_am_i_completed")
	return response


# Find a user_id from search_term returns limit amount of user_ids.
func search_user(search_term : String, limit : int = 10) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/user_directory/search"
	var body := {
		"limit" : limit,
		"search_term" : search_term,
	}
	_make_post_request(url, body, true, "_search_user_completed")
	var response = yield(self, "search_user_completed")
	return response


func get_displayname(user_id : String) -> Dictionary:
	var url := "https://matrix.org/_matrix/client/r0/profile/%s/displayname" % user_id
	_make_get_request(url, "_get_displayname_completed")
	var response = yield(self, "get_displayname_completed")
	return response


func download(media_id : String, allow_remote : bool = false, server : String = "matrix.org"):
	var url := "https://matrix.org/_matrix/media/r0/download/%s/%s?allow_remote=%s" % [server, media_id, (str(allow_remote).to_lower())]
	_make_get_request(url, "_download_completed")
	var response = yield(self, "download_completed")
	return response


func get_thumbnail(media_id : String, width : int, height : int, server : String = "matrix.org", method : String = "scale", allow_remote : bool = false):
	var url := "https://matrix.org/_matrix/media/r0/thumbnail/%s/%s?width=%s&height=%s&method=%s&allow_remote=%s" % [server, media_id, width, height, method, (str(allow_remote).to_lower())]
	_make_get_request(url, "_get_thumbnail_completed")
	var response = yield(self, "get_thumbnail_completed")
	return response


func preview_url(preview_url : String, ts : int = 0) -> Dictionary:
	var url := "https://matrix.org/_matrix/media/r0/preview_url?url=%s&ts=%s" % [preview_url, ts]
	_make_get_request(url, "_preview_url_completed")
	var response = yield(self, "preview_url_completed")
	return response


# Called when the login request is completed.
# Sets the access token that is used for all interactions with the server.
# NOTE : Prints "response" for debugging via API playground at matrix.org
func _login_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray):
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	if response_code == 200:
		# NOTE : access_token must be set before emitting signal.
		access_token = response["access_token"]
		user_identification = response["user_id"]
		print(JSON.print(response["access_token"], "\t"))
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("login_completed", response)


# Runs when the logout request completes.
# Requires an access token to know who is logging out.
func _logout_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray):
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		access_token = ""
		user_identification = ""
		emit_signal("logout_completed", true)
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
#			push_warning("Missing access token")
		emit_signal("logout_completed", false)


func _invite_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray):
	var _err_result := _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("invite_completed", response)


func _room_join_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)

	emit_signal("room_join_completed", response)


func _room_ban_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("room_ban_completed", response)


func _room_forget_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("room_forget_completed", response)


func _room_kick_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("room_kick_completed", response)


func _room_leave_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("room_leave_completed", response)


func _room_unban_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("room_unban_completed", response)


# Runs when synchronizaion completes.
# Sets the "next_batch" parameter that is used to paginate the server.
func _sync_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray):
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("sync_completed", response)


# Runs when send message has completed.
func _send_message_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray):
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("send_message_completed", true)


# Runs when get members completes
func _get_members_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("get_members_completed", response)


# Runs when create room completes.
func _create_room_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("create_room_completed", response)


# Runs when get joined rooms completes.
func _get_joined_rooms_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("get_joined_rooms_completed", response)


# Runs when get room by alias completes.
func _get_room_id_by_alias_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("get_room_id_by_alias_completed", response)


# Runs when get room aliases completes.
func _get_room_aliases_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("get_room_aliases_completed", response)


# Runs when get messages completes.
func _get_messages_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	emit_signal("get_messages_completed", response)


func _get_state_by_room_id_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Array = parse_json(body.get_string_from_ascii())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("get_state_by_room_id_completed", response)


func _get_room_name_by_room_id_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("get_room_name_by_room_id_completed", response)


func _message_redact_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)
	
	emit_signal("message_redact_completed", response)


# Get current user_id.
func _who_am_i_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)

	emit_signal("who_am_i_completed", response)


func _search_user_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)

	emit_signal("search_user_completed", response)


func _get_displayname_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)

	emit_signal("get_displayname_completed", response)


func _download_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response := body
	if response_code == 200:
		pass
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)

	emit_signal("download_completed", response)


func _preview_url_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_utf8())
	if response_code == 200:
		pass
	elif response_code == 500:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		print(error_string)
	else:
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)

	emit_signal("preview_url_completed", response)


func _get_thumbnail_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response = body
	if response_code == 200:
		pass
	else:
		response = parse_json(body.get_string_from_utf8())
		var error_string := "Error %s: " % response_code + "{errcode} : {error}".format(response)
		push_warning(error_string)

	emit_signal("get_thumbnail_completed", response)

# HTTPRequest POST mode.
# Connects a callback to functions in class for async behaviour.
func _make_post_request(url : String, data_to_send, use_ssl : bool, response : String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, response)
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers := ["Content-Type: application/json", "Authorization: Bearer %s" % access_token]
	var error = http_request.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
	
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	

# HTTPRequest PUT mode.
# Connects a callback to functions in class for async behaviour.
func _make_put_request(url : String, data_to_send, use_ssl : bool, response : String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, response)
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers := ["Content-Type: application/json", "Authorization: Bearer %s" % access_token]
	var error = http_request.request(url, headers, use_ssl, HTTPClient.METHOD_PUT, query)
	
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# HTTPRequest GET mode.
# Connects a callback to functions in class for async behaviour.
func _make_get_request(url : String, response : String):
	# Create an HTTP request node and connect its completion signal.
	var http_request := HTTPRequest.new()
	add_child(http_request)
	var _err = http_request.connect("request_completed", self, response)
	var headers := ["Content-Type: application/json", "Authorization: Bearer %s" % access_token]
	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_request.request(url, headers)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Checks if the HTTP request response is broken somehow.
func _check_result(result) -> bool:
	match(result):
		HTTPRequest.RESULT_SUCCESS:
			return true
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			push_error("Result chunked body size mismatch.")
			return false
		HTTPRequest.RESULT_CANT_CONNECT:
			push_error("Request failed while connecting.")
			return false
		HTTPRequest.RESULT_CANT_RESOLVE:
			push_error("Request failed while resolving.")
			return false
		HTTPRequest.RESULT_CONNECTION_ERROR:
			push_error("Request failed due to connection (read/write) error.")
			return false
		HTTPRequest.RESULT_SSL_HANDSHAKE_ERROR:
			push_error("Request failed on SSL handshake.")
			return false
		HTTPRequest.RESULT_NO_RESPONSE:
			push_error("Request does not have a response (yet).")
			return false
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			push_error("Request exceeded its maximum size limit, see body_size_limit.")
			return false
		HTTPRequest.RESULT_REQUEST_FAILED:
			push_error("Request failed (currently unused).")
			return false
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			push_error("HTTPRequest couldn’t open the download file.")
			return false
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			push_error("HTTPRequest couldn’t write to the download file.")
			return false
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			push_error("Request reached its maximum redirect limit, see max_redirects.")
			return false
		HTTPRequest.RESULT_TIMEOUT:
			push_error("Timeout!")
			return false
		_:
			push_error("Unexpected http client error!")
			return false

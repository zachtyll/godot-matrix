class_name MatrixProtocol
extends Node

enum Preset {
	PRIVATE_CHAT,
	PUBLIC_CHAT,
	TRUSTED_PRIVATE_CHAT
}

var access_token := ""
#var next_batch := "s9_13_0_1_1"

# Signals since it's async calls.
signal sync_completed
signal login_completed
signal logout_completed
signal room_joined_completed
signal send_message_completed
signal get_members_completed
signal create_room_completed
signal get_joined_rooms_completed
signal get_room_id_by_alias_completed
signal get_room_aliases_completed
signal get_messages_completed
signal get_state_by_room_id_completed
signal get_room_name_by_room_id_completed


# Logs a user into Matrix
# TODO : Make this work with any homeserver
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


# Logs out a session from the server
func logout():
	var url := "https://matrix.org/_matrix/client/r0/logout?access_token=" + access_token
	var body := {}
	
	_make_post_request(url, body, true, "_logout_completed")


# Registers a new user on Matrix.
# TODO : Make this work as intended.
# TODO : Allow for 3PID registration.
func register():
	print("Not implemented.")

# Sends a message to the server.
# NOTE : Message does not always mean "text message".
# NOTE : Returns a message ID for redactions and edits.
func send_message(room : String, message : String):
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room + "/send/m.room.message?access_token=" + access_token
	var content := {
		"msgtype" : "m.text",
		"body" : message
		}
	_make_post_request(url, content, true, "_send_message_completed")


# Syncs client state with server state.
# NOTE : Should be used only on startup.
# NOTE : Heavy workload.
func sync_events(filter : String = (""),  since : String = "s0", full_state : bool = false , set_presence : String = "offline", timeout : int = 0):
	var url := "https://matrix.org/_matrix/client/r0/sync?{0}&since={1}&full_state={2}&set_presence={3}&timeout={4}&access_token={5}".format([filter, since, (str(full_state).to_lower()), set_presence, timeout, access_token])
	_make_get_request(url, "_sync_completed")


# Joins the user to a room.
func join_room(room : String):
	var url := "https://matrix.org/_matrix/client/r0/join/" + room + "?access_token=" + access_token
	var body := {
		"room_alias_name": "test"
	}
	_make_post_request(url, body, true, "_join_room_completed")


# Gets all members of a room.
func get_members(room : String):
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room + "/joined_members?access_token=" + access_token
	_make_get_request(url, "_get_members_completed")


# Creates a new room.
func create_room(room_name : String, preset : int, room_alias_name : String, topic : String):
	var url := "https://matrix.org/_matrix/client/r0/createRoom?access_token=" + access_token
	var room_preset := ""
	
	match(preset):
		Preset.PRIVATE_CHAT:
			room_preset = "private_chat"
		Preset.PUBLIC_CHAT:
			room_preset = "public_chat"
		Preset.TRUSTED_PRIVATE_CHAT:
			room_preset = "trusted_private_chat"
			
	var body := {
		"creation_content": {
		"m.federate": false
		},
		"name": room_name,
		"preset": room_preset,
		"room_alias_name": room_alias_name,
		"topic": topic
	}
	_make_post_request(url, body, true, "_create_room_completed")


# Gets all rooms the user has joined.
func get_joined_rooms():
	var url := "https://matrix.org/_matrix/client/r0/joined_rooms?access_token=" + access_token
	_make_get_request(url, "_get_joined_rooms_completed")


# Gets a room id by reading an alias.
func get_room_id_by_alias(alias : String, homeserver : String = "matrix.org") -> void:
	var url := "https://matrix.org/_matrix/client/r0/directory/room/" + alias + homeserver + "?access_token=" + access_token
	_make_get_request(url, "_get_room_id_by_alias_completed")


# Gets an array of local aliases for a room.
# TODO : Figure out what "local" implies.
func get_room_aliases(room_id : String) -> void:
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/aliases?access_token=" + access_token
	_make_get_request(url, "_get_room_aliases_completed")


# Gets messages from room "room_id". Batch "from" to batch "to" with max "limit" messages.
# "dir" handles the direction to paginate. ("b"ackwards or "f"orwards).
# TODO : Figure out how "filter" works.
func get_messages(room_id : String, from : String = "", to : String = "", dir : String = "b", limit : int = 10, filter : String = ""):
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/messages?from=" + from + "&to=" + to + "&dir=" + dir + "&limit=" + str(limit) +  "&filter=" + filter + "&access_token=" + access_token
	_make_get_request(url, "_get_messages_completed")


func get_state_by_room_id(room_id : String) -> void:
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/state?access_token=" + access_token
	_make_get_request(url, "_get_state_by_room_id_completed")


func get_room_name_by_room_id(room_id : String) -> void:
	var url := "https://matrix.org/_matrix/client/r0/rooms/" + room_id + "/state/m.room.name/?access_token=" + access_token
	_make_get_request(url, "_get_room_name_by_room_id_completed")


# Called when the login request is completed.
# Sets the access token that is used for all interactions with the server.
# NOTE : Prints "response" for debugging via API playground at matrix.org
func _login_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray):
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	match(response_code):
		400:
			push_warning("Part of the request was invalid. For example, the login type may not be recognised.")
		403:
			push_warning("The login attempt failed. This can include one of the following error codes:")
		429:
			push_warning("This request was rate-limited.")
		200:
			print("Login success!")
			# NOTE : access_token must be set before emitting signal.
			print(JSON.print(response, "\t"))
			access_token = response.get("access_token")
			print(JSON.print(response.get("access_token"), "\t"))
		_:
			push_error("something unexpected happened: " + str(response_code))
	emit_signal("login_completed", response)

# Runs when the logout request completes.
# Requires an access token to know who is logging out.
func _logout_completed(result : int, response_code : int, _headers : PoolStringArray, _body : PoolByteArray):
	var _err_result = _check_result(result)
	match(response_code):
		200:
			access_token = ""
			print("Successfully logged out")
			emit_signal("logout_completed", true)
		401:
			push_warning("Missing access token")
			emit_signal("logout_completed", false)


# Runs when synchronizaion completes.
# Sets the "next_batch" parameter that is used to paginate the server.
func _sync_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray):
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	match(response_code):
		200:
			print("Sync success")
		401:
			push_warning("Missing access token")
	emit_signal("sync_completed", response)


# Runs when send message has completed.
func _send_message_completed(result : int, _response_code : int, _headers : PoolStringArray, _body : PoolByteArray):
	var _err_result = _check_result(result)
	emit_signal("send_message_completed", true)


# Runs when join room has completed.
# TODO : Remove unessecary return statement.
# TODO : Figure out if we actually need this signal to be emitted.
func _join_room_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	match(response_code):
		200:
			print("Join room success")
#			emit_signal("room_joined_completed", true)
		403:
			push_warning("An unkown error occurred")
#			emit_signal("room_joined_completed", false)
		429:
			push_warning("Too many requests")
#			emit_signal("room_joined_completed", false)
	emit_signal("room_joined_completed", response)


# Runs when get members completes
func _get_members_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	match(response_code):
		200:
			print("Get members success")
		403:
			push_warning("You are not a member of the room")
	emit_signal("get_members_completed", response)


# Runs when create room completes.
func _create_room_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	match(response_code):
		200:
			print("Room create success")
		400:
			push_warning("Unknown error occurred")
	emit_signal("create_room_completed", response)


# Runs when get joined rooms completes.
func _get_joined_rooms_completed(result : int, _response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	emit_signal("get_joined_rooms_completed", response)


# Runs when get room by alias completes.
func _get_room_id_by_alias_completed(result : int, _response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	emit_signal("get_room_id_by_alias_completed", response)


# Runs when get room aliases completes.
func _get_room_aliases_completed(result : int, _response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	emit_signal("get_room_aliases_completed", response)


# Runs when get messages completes.
func _get_messages_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	match(response_code):
		200:
			print("Get messages success")
		403:
			push_warning("You are not a member of this room")
	emit_signal("get_messages_completed", response)


func _get_state_by_room_id_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Array = parse_json(body.get_string_from_ascii())
	match(response_code):
		200:
			print("Get state success")
		403:
			push_warning("You aren't a member of the room and weren't previously a member of the room.")
	
	emit_signal("get_state_by_room_id_completed", response)


func _get_room_name_by_room_id_completed(result : int, response_code : int, _headers : PoolStringArray, body : PoolByteArray) -> void:
	var _err_result = _check_result(result)
	var response: Dictionary = parse_json(body.get_string_from_ascii())
	match(response_code):
		200:
			print("Get messages success")
		404:
			print("The room has no state with the given type or key.")
		403:
			push_warning("You aren't a member of the room and weren't previously a member of the room.")
	emit_signal("get_room_name_by_room_id_completed", response)
	


# HTTPRequest POST mode.
# Connects a callback to functions in class for assync behaviour.
func _make_post_request(url : String, data_to_send, use_ssl : bool, response : String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, response)
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
	
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	

# HTTPRequest PUT mode.
# Connects a callback to functions in class for assync behaviour.
func _make_put_request(url : String, data_to_send, use_ssl : bool, response : String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, response)
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, use_ssl, HTTPClient.METHOD_PUT, query)
	
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# HTTPRequest GET mode.
# Connects a callback to functions in class for assync behaviour.
func _make_get_request(url : String, response : String):
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, response)
	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Checks if the HTTP request response is broken somehow.
func _check_result(result) -> bool:
	match(result):
		HTTPRequest.RESULT_SUCCESS:
			print("Request successful.")
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


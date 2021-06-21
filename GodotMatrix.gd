extends Node


export(String) var user_username
export(String) var user_password

const matrix_protocol = preload( "Matrix.gd" )
const _model = "" # Might use the model straight inside of the framework.

enum GMRequest {
	LOGIN,
	LOGOUT,
	SYNC,
	CREATE_ROOM,
}

var mp : MatrixProtocol




func get_joined_rooms():
	pass


func login(username : String, password : String):
	var response = mp.login(username, password)
	var test = yield(response, "completed")
	return test


func logout():
	pass


func matrix_sync():
	var response = yield(mp, "sync_completed")


func create_room():
	pass


func GodotMatrix(request : int) -> GDScriptFunctionState:
	var response : GDScriptFunctionState
	match(request):
		GMRequest.LOGIN:
			 response = login(user_username, user_password)
		GMRequest.LOGOUT:
			response = logout()
		GMRequest.CREATE_ROOM:
			response = login(user_username, user_password)
		GMRequest.SYNC:
			response = login(user_username, user_password)
	return response


func _ready():
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)
	
	var test = yield(mp.login(user_username, user_password), "completed")
	print(test)
#	(room_id : String,
# from : String = "",
# to : String = "",
# dir : String = "b",
# limit : int = 10,
# filter : String = ""
	var types = ["m.room.name", "m.room.canonical_alias", "m.room.member"]
	for type in types:
		var test2 = yield(mp.get_messages("!KSOWjTcKFhwaFHTKny:matrix.org", "s0_0_0", "", "f", 10, '{"types":["%s"]}'% type), "completed")
		print(JSON.print(test2["chunk"].front(), "\t"))
		if test2["chunk"].has("content"):
			print("passes firts")
			if test2["content"].has("room_alias_name"):
				print(JSON.print(test2["room_alias_name"], "\t"))


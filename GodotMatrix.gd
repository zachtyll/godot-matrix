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


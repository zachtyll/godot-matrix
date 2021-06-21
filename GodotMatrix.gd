extends Node

const matrix_protocol = preload( "Matrix.gd" )
const _model = "" # Might use the model straight inside of the framework.

var mp : MatrixProtocol




func get_joined_rooms():
	pass


func login():
	pass


func logout():
	pass


func create_room():
	pass


func _ready():
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)


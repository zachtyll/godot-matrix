class_name GodotMatrix
extends Node

const matrix_protocol = preload("Matrix.gd")


#var access_token := ""
var login := false
var mp : MatrixProtocol
var room_counter := 0
var joined_rooms := {}
var synced_data := {}
var input_text := ""
var current_room : Room
var next_batch := ""
var previous_batch := ""
var chat_line := ""

var rooms_array := []


func _send_message() -> void:
	if chat_line.empty():
		return
	elif chat_line.begins_with(" "):
		return
	mp.send_message(current_room.room_id, input_text)
	chat_line = ""


func _ready():
	mp = matrix_protocol.new() as MatrixProtocol
	self.add_child(mp)
	
	var _sync_err = mp.connect("sync_completed", self, "_sync_to_server")
	var _login_err = mp.connect("login_completed", self, "_on_login_completed")
	var _get_joined_rooms_err = mp.connect("get_joined_rooms_completed", self, "_update_room_list")

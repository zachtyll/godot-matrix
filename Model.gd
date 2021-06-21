extends Node

var login := false
var mp : MatrixProtocol
var room_counter := 0
var joined_rooms := {}
var synced_data := {}
var input_text := ""
var current_room = ""
var next_batch := ""
var previous_batch := ""


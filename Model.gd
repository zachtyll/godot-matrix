class_name GodotMatrix
extends Node


class event:
	var content = {}
	var origin_server_ts = 0
	var sender = ""
	var state_key = ""
	var type = ""
	var unsigned = {
					age = 0,
				}
	var event_id = ""


class Room:
	var timeline := {
		events = [],
	}


	func get_content(index) -> Dictionary:
		return timeline["events"][index]["content"]
	
	
	func get_origin_server_ts(index) -> int:
		return timeline["events"][index]["origin_server_ts"]


	func get_sender(index) -> String:
		return timeline["events"][index]["sender"]


	func get_state_key(index) -> String:
		return timeline["events"][index]["state_key"]


	func get_type(index) -> String:
		return timeline["events"][index]["type"]


	func get_unsigned(index) -> Dictionary:
		return timeline["events"][index]["unsigned"]


	func get_event_id(index) -> String:
		return timeline["events"][index]["event_id"]


var login := false
var room_counter := 0
var joined_rooms := {}
var synced_data := {}
var input_text := ""
var current_room = ""
var next_batch := ""
var previous_batch := ""




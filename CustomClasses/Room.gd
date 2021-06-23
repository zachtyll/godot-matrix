class_name Room
extends Node
# Model for a Matrix room.



class Timeline:
# Container for all events in a room.
	var events = []
	
	
	func event_append(event : Event) -> bool:
		if event is Event:
			events.append(event)
			return true
		else:
			push_error("Timeline rejects: %s" % event)
			return false
	
	
	func get_content(index) -> Dictionary:
		return events[index]["content"]
	
	
	func get_origin_server_ts(index) -> int:
		return events[index]["origin_server_ts"]
	
	
	func get_sender(index) -> String:
		return events[index]["sender"]
	
	
	func get_state_key(index) -> String:
		return events[index]["state_key"]
	
	
	func get_type(index) -> String:
		return events[index]["type"]
	
	
	func get_unsigned(index) -> Dictionary:
		return events[index]["unsigned"]
	
	
	func get_event_id(index) -> String:
		return events[index]["event_id"]


var room_id : String = ""
var room_membership : int = 0
var timeline : Timeline = Timeline.new()




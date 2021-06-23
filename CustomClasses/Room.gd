class_name Room
extends Node
# Model for a Matrix room.



class Timeline:
# Container for all events in a room.
	var events = []
	
	
	func _init(new_timeline):
		for event in new_timeline["events"]:
			var new_event = Event.new(event)
			event_append(new_event)


	func event_append(event : Event) -> void:
		if event is Event:
			events.append(event)
		else:
			push_error("Timeline rejects: %s" % event)
	
	
	func get_content(index) -> Dictionary:
		return events[index]["content"]
	
	
	func get_origin_server_ts(index) -> int:
		return events[index]["origin_server_ts"]
	
	
	func get_sender(index) -> String:
		return events[index]["sender"]
	
	
	func get_state_key(index) -> String:
		return events[index]["state_key"]
	
	
	func get_event_type(index) -> String:
		return events[index]["type"]
	
	
	func get_unsigned(index) -> Dictionary:
		return events[index]["unsigned"]
	
	
	func get_event_id(index) -> String:
		return events[index]["event_id"]


var room_id : String = ""
var room_name : String = ""
var room_membership : int = 0

# Room keys
var timeline : Timeline = null
var state
var account_data
var ephemeral
var unread_notifications
var summary
var org_matrix_msc2654_unread_count


func _init(new_room_data : Dictionary):
	timeline = Timeline.new(new_room_data["timeline"])
	print(JSON.print(timeline, "\t"))


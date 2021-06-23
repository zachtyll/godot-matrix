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


var room_id := ""
var room_name := ""
var room_alias := ""
var room_membership := 0

# Room keys
var timeline : Timeline = null
var state
var account_data
var ephemeral
var unread_notifications
var summary
var org_matrix_msc2654_unread_count


func _init(username : String, new_room_id : String, new_room_data : Dictionary):
	timeline = Timeline.new(new_room_data["timeline"])
	state = new_room_data["state"]
	room_id = new_room_id
	_get_room_name(username)


# Massive function to translate room_id into human-readable names.
# TODO : Move this algo into the Room class.
func _get_room_name(username : String) -> void:
	var room_member_name := ""
	for event in timeline.events:
		match(event.type):
			"m.room.name":
				room_name = event.content["name"]
			"m.room.canonical_alias":
				room_alias = event.content["alias"]
			"m.room.member":
				if not event.content["displayname"] == username:
					room_member_name = event.content["displayname"]
	if not room_name.empty():
		return
	elif not room_alias.empty():
		room_name = room_alias.split(":")[0]
	elif not room_member_name.empty():
		room_name = room_member_name
	else:
		room_name = str(self)

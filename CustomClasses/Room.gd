class_name Room
extends Node
# Model for a Matrix room.


# Container for all recorded events in a room.
class Timeline:
	var events := []
	
	
	func _init(new_timeline : Dictionary):
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


# Container for all recorded state updates of a room
class State:
	var events := []


	func _init(new_state : Dictionary):
		for event in new_state["events"]:
			var new_event = Event.new(event)
			event_append(new_event)


	func event_append(event : Event) -> void:
		if event is Event:
			events.append(event)
		else:
			push_error("Timeline rejects: %s" % event)


	func get_event(index : int) -> Event:
		return events[index]


var room_id := ""
var room_name := ""
var room_alias := ""
var room_topic := ""
var room_membership := 0

# Events that are availiable from sync.
var timeline : Timeline = null
# Room state events not included in timeline.
var state : State = null
var account_data
var ephemeral
var unread_notifications
var summary
var org_matrix_msc2654_unread_count


func _init(username : String, new_room_id : String, new_room_data : Dictionary):
	timeline = Timeline.new(new_room_data["timeline"])
	state = State.new(new_room_data["state"])
	room_id = new_room_id
	_get_room_name(username)
	_get_room_topic()


# Massive function to translate room_id into human-readable names.
# TODO : Move this algo into the Room class.
func _get_room_name(username : String) -> void:
	var room_member_name := ""
	# Must check state.events for rooms with a lot of message events.
	for event in (timeline.events + state.events):
		match(event.type):
			"m.room.name":
				room_name = event.content["name"]
			"m.room.canonical_alias":
				room_alias = event.content["alias"]
			"m.room.member":
				if not event.content["membership"] == "leave":
					if event.content.has("room_alias_name"):
						room_member_name = event.content["room_alias_name"]
					elif not event.content["displayname"] == username:
						room_member_name = event.content["displayname"]
	if not room_name.empty():
		return
	elif not room_alias.empty():
		room_name = room_alias.split(":")[0]
	elif not room_member_name.empty():
		room_name = room_member_name
	else:
		room_name = str(self)


func _get_room_topic():
	# Must check state.events for rooms with a lot of message events.
	for event in (timeline.events + state.events):
		if event.type == "m.room.topic":
			room_topic = event.content["topic"]

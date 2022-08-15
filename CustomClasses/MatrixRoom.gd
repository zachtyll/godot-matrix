class_name MatrixRoom
extends Node
# Model for a Matrix room.


# Container for all recorded events in a room.
class Timeline:
	var timeline_events := []
	
	
	func _init(new_timeline : Dictionary):
		for event in new_timeline["events"]:
			var new_event = Event.new(event)
			event_append(new_event)


	func event_append(event : Event) -> void:
		if event is Event:
			timeline_events.append(event)
		else:
			push_error("Timeline rejects: %s" % event)
	
	
	func content(index) -> Dictionary:
		return timeline_events[index]["content"]
	
	
	func origin_server_ts(index) -> int:
		return timeline_events[index]["origin_server_ts"]
	
	
	func sender(index) -> String:
		return timeline_events[index]["sender"]
	
	
	func state_key(index) -> String:
		return timeline_events[index]["state_key"]
	
	
	func event_type(index) -> String:
		return timeline_events[index]["type"]
	
	
	func unsigned(index) -> Dictionary:
		return timeline_events[index]["unsigned"]
	
	
	func event_id(index) -> String:
		return timeline_events[index]["event_id"]
	
	
	func events() -> Array:
		return timeline_events


# Container for all recorded state updates of a room
class State:
	var state_events := []


	func _init(new_state : Dictionary):
		for event in new_state["events"]:
			var new_event = Event.new(event)
			event_append(new_event)


	func event_append(event : Event) -> void:
		if event is Event:
			state_events.append(event)
		else:
			push_error("Timeline rejects: %s" % event)


	func event(index : int) -> Event:
		return state_events[index]


	func events() -> Array:
		return state_events


## Room variables.
enum RoomMembership {
	LEAVE,
	INVITE,
	JOIN,
	KNOCK # Not used.
}

const MEDIA_ID_LENGTH = 17

var room_id := ""
var room_name := ""
var room_alias := ""
var room_avatar_url := ""
var room_topic := ""
var room_membership := 0

# Events that are availiable from sync.
var room_timeline : Timeline = null
# Room state events not included in timeline.
var state : State = null
var account_data
var ephemeral
var unread_notifications
var summary
var org_matrix_msc2654_unread_count


func _init(username : String, new_room_id : String, new_room_data : Dictionary):
	room_timeline = Timeline.new(new_room_data["timeline"])
	state = State.new(new_room_data["state"])
	room_id = new_room_id
	_get_room_name(username)
	room_avatar_url = _get_room_avatar_url()
	room_topic = _get_room_topic()


# Translate room_id into human-readable names.
func _get_room_name(username : String) -> void:
	var room_member_name := ""
	# Must check state.events for rooms with a lot of message events.
	for event in (room_timeline.events() + state.events()):
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


# Finds the latest url to the avatar used for the room.
func _get_room_avatar_url() -> String:
	var url
	# Must check state.events for rooms with a lot of message events.
	for event in (room_timeline.events() + state.events()):
		if event.type == "m.room.avatar":
			url = event.content["url"]
#	print(url)
	return url


func _get_room_topic() -> String:
	var new_topic := ""
	# Must check state.events for rooms with a lot of message events.
	for event in (room_timeline.events() + state.events()):
		if event.type == "m.room.topic":
			new_topic = event.content["topic"]
	return new_topic


## Declarative functions.
func display_name() -> String:
	return room_name


func alias() -> String:
	return room_alias


func id() -> String:
	return room_id


func topic() -> String:
	return room_topic


func avatar_url() -> String:
	return room_avatar_url


func timeline() -> Timeline:
	return room_timeline

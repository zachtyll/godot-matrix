extends ScrollContainer
class_name ChatWindow

const m_text = preload("res://MessageBoxes/RoomMessage.tscn")
const m_rga = preload("res://MessageBoxes/RoomGuestAccess.tscn")

onready var timeline := $TimeLine


func clear() -> void:
	var message_boxes := timeline.get_children()
	for message_box in message_boxes:
		message_box.queue_free()


# warning-ignore:unused_argument
# Returns an enumeration. 0: OK, 1: Fail.
func add_message(new_event : Event) -> int:
	var message_box
	match(new_event.type):
		"m.room.message":
			match(new_event.content["msgtype"]):
				"m.text":
					message_box = m_text.instance()
					message_box.event = new_event
#					message_box.sender = chunk["sender"]
					# This seems to be broken currently, or I've missunderstood timestamps.
#					var time_stamp = OS.get_datetime_from_unix_time(chunk["origin_server_ts"))
#					message_box.time_stamp = "{hour}:{minute}:{second} {year}/{month}/{day}".format(time_stamp)
#					message_box.event_id = chunk["event_id"]
#					message_box.body = (
#						"{body}".format(chunk["content"])
#						)
				_:
					pass
#					message_box.sender = (
#						"This is a: {msgtype}".format(chunk["msgtype"])
#					)
#					message_box.body = (
#						"{body}".format(chunk["content"])
#					)
		"m.room.guest_access":
			message_box = m_rga.instance()
			message_box.event = new_event
			if new_event.content.has("guest_access"):
#				message_box.sender = ""
				message_box.body = (
					"[center]Guest access set to: {guest_access}![/center]".format(new_event.content)
					)
				
			else:
#				message_box.sender = "WARNING: Unexpected message"
				message_box.body = (
					"Unexpected content block: {content}!".format(new_event.content)
					)
		"m.room.member":
			message_box = m_text.instance()
			message_box.event = new_event
#			message_box.sender = ""
			message_box.body += "[center]"
			message_box.body += (
				"{displayname} {membership}".format(new_event.content)
				)
			if new_event.content.has("room_alias_name"):
				message_box.body += " {room_alias_name}.[/center]".format(new_event.content)
			else:
				message_box.body += "[/center]"
		"m.room.create":
			message_box = m_text.instance()
			message_box.event = new_event
			message_box.body = (
				"[center]{creator} created the room. Version: {room_version}[/center]".format(new_event.content)
			)
		"m.room.history_visibility":
			message_box = m_text.instance()
			message_box.event = new_event
			message_box.body = (
				"[center]Message history set to: {history_visibility}[/center]".format(new_event.content)
			)
		"m.room.join_rules":
			message_box = m_text.instance()
			message_box.event = new_event
			# TODO : Fix the formatting to be like natural language.
			message_box.body = (
				"[center]Join rule set to: {join_rule}.[/center]".format(new_event.content)
			)
		"m.room.canonical_alias":
			message_box = m_text.instance()
			message_box.event = new_event
#			message_box.sender = ""
			message_box.body = (
				"[center]Canonical alias: {alias}.[/center]".format(new_event.content)
			)
		"m.room.topic":
			message_box = m_text.instance()
			message_box.event = new_event
			if new_event.content.has("topic"):
#				topic.text = content["content")["topic")
				message_box.body = (
					"[center]The topic was set to: {topic}[/center]".format(new_event.content)
				)
		"m.room.name":
			message_box = m_text.instance()
			message_box.event = new_event
			message_box.body = (
					"[center]Room name set to: {name}.[/center]".format(new_event.content)
				)
		"m.room.power_levels":
			message_box = m_text.instance()
			message_box.event = new_event
#			message_box.sender = "TODO : Implement m.room.power_levels"
			message_box.body = (
				"{content}".format(new_event.content)
			)
		"m.room.encryption":
			message_box = m_text.instance()
			message_box.event = new_event
			# TODO : Figure out wether this statement is actually
			#	completely true.
			message_box.body = (
					"[center]Messages are encrypted with: {algorithm}.[/center]".format(new_event.content)
				)
		"m.room.encrypted":
			message_box = m_text.instance()
			message_box.event = new_event
			# TODO : Figure out how to solve decryption.
			#	Maybe this shouldn't even be decrypted?
			#	Spec is a little unclear.
			message_box.body = (
					"[center]This message is encrypted.[/center]"
				)
		"m.reaction":
			message_box = m_text.instance()
			message_box.event = new_event
#			message_box.sender = "TODO : Implement m.reation"
			message_box.body = (
				"{content}".format(new_event.content)
			)
		"m.room.redaction":
			message_box = m_text.instance()
			message_box.event = new_event
#			message_box.sender = "TODO : Implement m.redaction"
			message_box.body = (
				"{content}".format(new_event.content)
			)
		_:
			message_box = null
			push_warning("Unhandled message in content block: " + str(new_event.type))

	if message_box == null:
		return FAILED
	else:
		timeline.add_child(message_box)
	return OK

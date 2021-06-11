extends ScrollContainer
class_name ChatWindow

const m_text = preload("res://MessageBoxes/MessagePanel.tscn")

onready var timeline := $TimeLine


func clear() -> void:
	var message_boxes := timeline.get_children()
	for message_box in message_boxes:
		message_box.queue_free()


# warning-ignore:unused_argument
# Returns an enumeration. 0: OK, 1: Fail.
func add_message(message_type : String, content : Dictionary) -> int:
	var message_box = m_text.instance()
	match(content.get("type")):
		"m.room.message":
			match(content.get("content").get("msgtype")):
				"m.text":
					message_box.sender = content.get("sender")
					message_box.body = (
						"{body}".format(content.get("content"))
						)
				_:
					message_box.body = (
						"This is a: {msgtype}".format(content.get("msgtype"))
					)
		"m.room.guest_access":
			if content.get("content").has("guest_access"):
				message_box.sender = ""
				message_box.body = (
					"Guest access set to: {guest_access}!".format(content.get("content"))
					)
				
			else:
				message_box.sender = "WARNING: Unexpected message"
				message_box.body = (
					"Unexpected content block: {content}!".format(content.get("content"))
					)
		"m.room.member":
				message_box.sender = ""
#				message_box.message_body.append_bbcode("")
				message_box.body = (
					"[wave amp=50 freq=2] {displayname} {membership} [/wave]".format(content.get("content"))
					)
#				message_box.message_body.append_bbcode("[/wave]")
				if content.get("content").has("room_alias_name"):
					message_box.body += " {room_alias_name}.".format(content.get("content"))
		"m.room.create":
			message_box.body = (
				"{creator} created the room. Version: {room_version}".format(content.get("content"))
			)
		"m.room.history_visibility":
			message_box.body = (
				"Message history set to: {history_visibility}".format(content.get("content"))
			)
		"m.room.join_rules":
			# TODO : Fix the formatting to be like natural language.
			message_box.body = (
				"Join rule set to: {join_rule}.".format(content.get("content"))
			)
		"m.room.canonical_alias":
			message_box.sender = "TODO : Implement m.room.canonical_alias"
			message_box.body = (
				"{content}".format(content)
			)
		"m.room.topic":
			if content.get("content").has("topic"):
#				topic.text = content.get("content").get("topic")
				message_box.body = (
					"The topic was set to: {topic}".format(content.get("content"))
				)
		"m.room.name":
			message_box.body = (
					"Room name set to: {name}".format(content.get("content"))
				)
#			channel_name.set_text(content.get("content").get("name"))
		"m.room.power_levels":
			message_box.sender = "TODO : Implement m.room.power_levels"
			message_box.body = (
				"{content}".format(content)
			)
		"m.room.encryption":
			# TODO : Figure out wether this statement is actually
			#	completely true.
			message_box.body = (
					"Messages are encrypted with: {algorithm}".format(content.get("content"))
				)
		"m.room.encrypted":
			# TODO : Figure out how to solve decryption.
			#	Maybe this shouldn't even be decrypted?
			#	Spec is a little unclear.
			message_box.body = (
					"This message is encrypted."
				)
		"m.reaction":
			message_box.sender = "TODO : Implement m.reation"
			message_box.body = (
				"{content}".format(content)
			)
		"m.room.redaction":
			message_box.sender = "TODO : Implement m.redaction"
			message_box.body = (
				"{content}".format(content)
			)
		_:
			message_box = null
			push_warning("Unhandled message in content block: " + str(content.get("type")))
	
	if message_box == null:
		return FAILED
	else:
		timeline.add_child(message_box)
		return OK

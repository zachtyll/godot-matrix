extends ScrollContainer
class_name ChatWindow

const m_text = preload("res://MessageBoxes/MessagePanel.tscn")

onready var timeline := $TimeLine


func add_message(message_type : String, content : Dictionary):
	timeline.add_child(_compose_message_box(message_type, content))


func clear() -> void:
	var message_boxes := timeline.get_children()
	for message_box in message_boxes:
		message_box.queue_free()


# warning-ignore:unused_argument
func _compose_message_box(message_type : String, content : Dictionary):
	var message_box = null
	match(content.get("type")):
		"m.room.message":
			match(content.get("content").get("msgtype")):
				"m.text":
					message_box = m_text.instance()
					message_box.sender = content.get("sender")
					message_box.body = content.get("content").get("body")
					return message_box
				_:
					print("Can only handle text right now!")
					print("This is a: " + str(content.get("msgtype")))
		"m.room.guest_access":
			if content.get("content").has("guest_access"):
				message_box = m_text.instance()
				message_box.sender = ""
				message_box.body += "Guest access set to: "
				message_box.body += content.get("content").get("guest_access")
				return message_box
			else:
				print("Unexpected content block:")
				print(content.get("content"))
#		"m.room.member":
#				message_line += content.get("content").get("displayname")
#				message_line += " "
#				message_line += content.get("content").get("membership")
#				if content.get("content").has("room_alias_name"):
#					message_line += " "
#					message_line += content.get("content").get("room_alias_name")
#		"m.room.create":
#			message_line += content.get("content").get("creator")
#			message_line += " created the room. Room version: "
#			message_line += content.get("content").get("room_version")
#		"m.room.history_visibility":
#			message_line += "Message history set to: "
#			message_line += content.get("content").get("history_visibility")
#		"m.room.join_rules":
#			# TODO : Fix the formatting to be like natural language.
#			message_line += "Join rule set to: "
#			message_line += content.get("content").get("join_rule")
#		"m.room.canonical_alias":
#			print("TODO : Implement m.room.canonical_alias")
#			print(content.get("content"))
#		"m.room.topic":
#			print("TODO : Implement m.room.topic")
#			if content.get("content").has("topic"):
#				topic.text = content.get("content").get("topic")
#				message_line += "The topic was set to: "
#				message_line += content.get("content").get("topic")
#		"m.room.name":
#			message_line += "Room name set to: "
#			message_line += content.get("content").get("name")
#			channel_name.set_text(content.get("content").get("name"))
#		"m.room.power_levels":
#			print("TODO : Implement m.room.power_levels")
#			print(content.get("content"))
#		"m.room.encryption":
#			# TODO : Figure out wether this statement is actually
#			#	completely true.
#			message_line += "Messages are encrypted with "
#			message_line += content.get("content").get("algorithm")
#		"m.room.encrypted":
#			# TODO : Figure out how to solve decryption.
#			#	Maybe this shouldn't even be decrypted?
#			#	Spec is a little unclear.
#			message_line += "This message is encrypted."
#		"m.reaction":
#			print("TODO : Implement m.reation")
#			print(content.get("content"))
#		"m.room.redaction":
#			print("TODO : Implement m.redaction")
#			print(content.get("content"))
		_:
			push_warning("Unhandled message in content block: " + str(content.get("type")))

extends ScrollContainer
class_name ChatWindow

const m_text := preload("res://MessageBoxes/RoomMessage.tscn")
const m_rga := preload("res://MessageBoxes/RoomGuestAccess.tscn")
const m_rm := preload("res://MessageBoxes/RoomMember.tscn")
const m_rc := preload("res://MessageBoxes/RoomCreate.tscn")
const m_hv := preload("res://MessageBoxes/RoomHistoryVisibility.tscn")
const m_jr := preload("res://MessageBoxes/RoomJoinRules.tscn")
const m_ca := preload("res://MessageBoxes/CanonicalAlias.tscn")
const m_t := preload("res://MessageBoxes/Topic.tscn")
const m_n := preload("res://MessageBoxes/Name.tscn")
const m_pl := preload("res://MessageBoxes/PowerLevels.tscn")
const m_ion := preload("res://MessageBoxes/Encryption.tscn")
const m_ted := preload("res://MessageBoxes/Encrypted.tscn")
const m_rea := preload("res://MessageBoxes/Reaction.tscn")
const m_red := preload("res://MessageBoxes/Redaction.tscn")


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
				_:
					push_warning("No implementation for: {msgtype}".format(new_event.content))
		"m.room.guest_access":
			message_box = m_rga.instance()
			message_box.event = new_event
		"m.room.member":
			message_box = m_rm.instance()
			message_box.event = new_event
		"m.room.create":
			message_box = m_rc.instance()
			message_box.event = new_event
		"m.room.history_visibility":
			message_box = m_hv.instance()
			message_box.event = new_event
		"m.room.join_rules":
			message_box = m_jr.instance()
			message_box.event = new_event
		"m.room.canonical_alias":
			message_box = m_ca.instance()
			message_box.event = new_event
		"m.room.topic":
			message_box = m_t.instance()
			message_box.event = new_event
		"m.room.name":
			message_box = m_n.instance()
			message_box.event = new_event
		"m.room.power_levels":
			message_box = m_pl.instance()
			message_box.event = new_event
		"m.room.encryption":
			message_box = m_ion.instance()
			message_box.event = new_event
		"m.room.encrypted":
			message_box = m_ted.instance()
			message_box.event = new_event
		"m.reaction":
			message_box = m_rea.instance()
			message_box.event = new_event
		"m.room.redaction":
			message_box = m_red.instance()
			message_box.event = new_event
		_:
			message_box = null
			push_warning("Unhandled message type: " + str(new_event.type))

	if message_box == null:
		return FAILED
	else:
		timeline.add_child(message_box)
	return OK

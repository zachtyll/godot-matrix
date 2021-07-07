class_name RoomList
extends ScrollContainer

const default_room := preload("res://RoomListItem.tscn")

signal room_selected

var previous_room : RoomListItem = null

onready var list := $VBoxContainer


func add_room(room : Room) -> void:
	var new_room := default_room.instance()
	new_room.room = room
	new_room.index = list.get_child_count()
	var err = new_room.connect("room_lmb_selected", self, "_on_room_selected")
	if err:
		push_warning("ERROR in RoomList: %s" % err)
	list.add_child(new_room)


func clear() -> void:
	var items := list.get_children()
	for rooms in items:
		rooms.queue_free()


func _on_room_selected(index : int):
	var selected = list.get_child(index)
	if not previous_room == null:
		previous_room.message_selection()
	selected.message_selection()
	previous_room = selected
	emit_signal("room_selected", selected.room)

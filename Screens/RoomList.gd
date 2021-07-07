class_name RoomList
extends ScrollContainer

const default_room := preload("res://RoomListItem.tscn")

signal room_selected

var previous_room : Room

onready var list := $VBoxContainer


func add_room(room : Room) -> void:
	var new_room := default_room.instance()
	new_room.name = room.room_name # So we may find the right child.
	new_room.room = room
	var err = new_room.connect("room_lmb_selected", self, "_on_room_selected")
	if err:
		push_warning("ERROR in RoomList: %s" % err)
	list.add_child(new_room)


func clear() -> void:
	var items := list.get_children()
	for rooms in items:
		rooms.queue_free()


func _on_room_selected(room : Room):
	list.get_node(room.room_name)
	previous_room = room
	emit_signal("room_selected", room)

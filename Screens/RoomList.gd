class_name RoomList
extends ScrollContainer

const default_room := preload("res://RoomListItem.tscn")

signal room_selected

var previous_room : RoomListItem = null
var room_texture : ImageTexture

onready var list := $VBoxContainer


func add_room(room : Room):
	var new_room := default_room.instance()
	new_room.room = room
	new_room.index = list.get_child_count()
	var err = new_room.connect("room_lmb_selected", self, "_on_room_selected")
	if err:
		push_warning("ERROR in RoomList: %s" % err)
	if not room.room_avatar_url == null:
		var response = yield(GodotMatrix.download(room.room_avatar_url), "completed")
		if response is Dictionary:
			push_warning(response["error"])
			return response
		else:
			room_texture = response
	else:
		# TODO : Implement placeholder texture
		pass
	new_room.avatar_texture = room_texture
	list.add_child(new_room)


func clear() -> void:
	var items := list.get_children()
	for rooms in items:
		rooms.queue_free()


func _on_room_selected(index : int):
	# Deselect previously selected room.
	if is_instance_valid(previous_room):
		previous_room.message_selection()
	var selected = list.get_child(index)
	selected.message_selection()
	previous_room = selected
	emit_signal("room_selected", selected.room)

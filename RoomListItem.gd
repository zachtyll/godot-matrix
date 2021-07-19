class_name RoomListItem
extends PanelContainer
# Class for displaying room items data in the room list.

signal room_lmb_selected

var room : Room
var index := 0
var selected := false

onready var avatar := $HBoxContainer/Avatar
onready var label_name := $HBoxContainer/VBoxContainer/Name
onready var label_topic := $HBoxContainer/VBoxContainer/Topic


func _gui_input(input_event):
	if not input_event is InputEventMouseButton:
		return
	
	match(input_event.get_button_index()):
		BUTTON_LEFT:
			if input_event.pressed:
				emit_signal("room_lmb_selected", index)
		BUTTON_RIGHT:
			print("Right click!")


func message_selection() -> void:
	if selected:
		selected = false
		self_modulate = self_modulate - Color.gray
	else:
		self_modulate = self_modulate + Color.gray
		selected = true


func _get_avatar_texture(url : String):
	avatar.texture = yield(GodotMatrix.download(url), "completed")


# Called when the node enters the scene tree for the first time.
func _ready():
	if not room.room_avatar_url == null:
		var texture = ImageTexture.new()
		texture = _get_avatar_texture(room.room_avatar_url)
		avatar.texture = texture
	else:
		# Fallback when getting error.
		var texture = ImageTexture.new()
		avatar.texture = texture

	label_name.text = room.room_name
	label_topic.text = room.room_topic

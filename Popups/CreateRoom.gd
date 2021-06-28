extends WindowDialog

onready var room_name := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Name
onready var room_alias := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Alias
onready var status_label := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/StatusLabel


func _on_CreateRoom_about_to_show():
	room_name.clear()


func _on_Next_pressed():
	if room_alias.text.empty():
		status_label.text = "An alias is required."
	else:
		GodotMatrix.room_create(
			room_alias.text,
			room_name.text
		)


func _on_Cancel_pressed():
	self.hide()

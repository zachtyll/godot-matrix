extends WindowDialog

onready var room_name := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Name
onready var room_alias := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Alias
onready var status_label := $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/StatusLabel

signal create_room


func _on_CreateRoom_about_to_show():
	room_name.clear()


func _on_Next_pressed():
	emit_signal("create_room", room_name.text, room_alias.text)


func _on_Cancel_pressed():
	self.hide()

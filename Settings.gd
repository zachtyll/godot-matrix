extends Panel

var size := get_rect().size
var darken_screen := false

onready var tween := $Tween


func appear() -> void:
	get_parent().darken_screen()
	tween.interpolate_property(self, "rect_global_position",
		Vector2(-size.x, 0), Vector2(0, 0), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func disappear() -> void:
	get_parent().brighten_screen()
	tween.interpolate_property(self, "rect_global_position",
		Vector2(0, 0), Vector2(-size.x, 0), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func _on_Close_pressed():
	disappear()


func _input(event):
	if not event is InputEventMouseButton:
		return
	elif event.pressed and event.position > size:
		disappear()
	else:
		return


func _ready():
	rect_global_position = Vector2(-size.x, 0)

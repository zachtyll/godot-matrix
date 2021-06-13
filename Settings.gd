extends Panel

var size_x := get_rect().size.x
var darken_screen := false

onready var tween := $Tween


func appear() -> void:
	get_parent().darken_screen()
	tween.interpolate_property(self, "rect_global_position",
		Vector2(-size_x, 0), Vector2(0, 0), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func disappear() -> void:
	get_parent().brighten_screen()
	tween.interpolate_property(self, "rect_global_position",
		Vector2(0, 0), Vector2(-size_x, 0), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func _on_Close_pressed():
	disappear()


func _ready():
	rect_global_position = Vector2(-size_x, 0)

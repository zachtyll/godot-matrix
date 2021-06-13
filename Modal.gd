extends ColorRect

onready var tween := $Tween

func _ready():
	color = Color(0, 0, 0, 0.0)


func darken_screen():
	tween.interpolate_property(self, "color",
		Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.5), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func brighten_screen():
	tween.interpolate_property(self, "color",
		Color(0, 0, 0, 0.5), Color(0, 0, 0, 0.0), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

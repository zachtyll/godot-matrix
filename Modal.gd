extends ColorRect

onready var tween := $Tween


func _ready():
	color = Color(0, 0, 0, 0.0)


func darken_screen():
	# Doesn't replay effect if already dark.
	if not color == Color(0, 0, 0, 0.0):
		return
	tween.interpolate_property(self, "color",
		Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.5), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()


func brighten_screen():
	# Doesn't replay effect if already bright.
	if not color == Color(0, 0, 0, 0.5):
		return
	tween.interpolate_property(self, "color",
		Color(0, 0, 0, 0.5), Color(0, 0, 0, 0.0), 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

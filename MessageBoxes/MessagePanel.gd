class_name MessagePanel
extends Panel
# Parent class for all message-boxes.

const HEADER_SIZE := 50
const FOOTER_SIZE := 20
const LINE_LENGTH := 100
const TEXT_WIDTH := 4
const TEXT_HEIGHT := 16

var sender_message := ""
var time_stamp := ""
var body := ""
var line_count := 0
var selected := false
# Color variables
var red := 0
var green := 0
var blue := 0
var sender_color := Color8(100, 100, 100).to_html()

onready var event : Event setget set_event, get_event


# warning-ignore:narrowing_conversion
# NOTE: We don't care about more than integer precision.
func _adjust_for_lines() -> void:
	line_count = ceil(body.length() / float(LINE_LENGTH))
	set_custom_minimum_size(Vector2(LINE_LENGTH * TEXT_WIDTH, (line_count * TEXT_HEIGHT) + HEADER_SIZE + FOOTER_SIZE))


func _print_and_check(label : RichTextLabel, message : String) -> void:
	var err := label.append_bbcode(message)
	if err:
		push_error("BBCode failed with error: %s" % err)


func _message_selection() -> void:
	if selected:
		selected = false
		modulate = modulate - Color.gray
	else:
		modulate = modulate + Color.gray
		selected = true


func _set_message_content():
	pass


func get_event() -> Event:
	return event


func set_event(new_event : Event) -> void:
	event = new_event
	_set_message_content()
	_adjust_for_lines()


func _on_MessagePanel_gui_input(input_event):
	if not input_event is InputEventMouseButton:
		return
	
	match(input_event.get_button_index()):
		BUTTON_LEFT:
			if input_event.pressed:
				_message_selection()
		BUTTON_RIGHT:
			print("Left click!")

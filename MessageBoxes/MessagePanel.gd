extends Panel

const HEADER_SIZE := 50
const FOOTER_SIZE := 20
const LINE_LENGTH := 100
const TEXT_WIDTH := 4
const TEXT_HEIGHT := 16


var sender := ""
var time_stamp := "TIMESTAMP"
var body := ""
var line_count := 0

onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func _ready():
	_print_and_check(sender_name, sender)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)


# warning-ignore:narrowing_conversion
# NOTE: We don't care about more than integer precision.
	line_count = ceil(body.length() / float(LINE_LENGTH))
	set_custom_minimum_size(Vector2(LINE_LENGTH * TEXT_WIDTH, (line_count * TEXT_HEIGHT) + HEADER_SIZE + FOOTER_SIZE))


func _print_and_check(label : RichTextLabel, message : String) -> void:
	var err := label.append_bbcode(message)
	if err:
		push_error("BBCode failed with error: %s" % err)

extends Panel

const HEADER_SIZE := 50
const TEXT_SIZE := 16

var body := ""
var sender := ""

onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func _ready():
	sender_name.append_bbcode(sender)
	message_body.print_bbcode_message(body)
	set_custom_minimum_size(Vector2(0, (message_body.get_line_count() * TEXT_SIZE) + HEADER_SIZE))

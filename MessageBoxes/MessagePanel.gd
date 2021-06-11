extends Panel

const HEADER_SIZE := 50
const FOOTER_SIZE := 20
const LINE_LENGTH := 100
const TEXT_WIDTH := 4
const TEXT_HEIGHT := 16

var body := ""
var sender := ""
var line_count := 0

onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func _ready():
	sender_name.append_bbcode(sender)
	message_body.append_bbcode(body)
	
	line_count = ceil(body.length() / float(LINE_LENGTH))
	print("Line count is: " + str(line_count))
	set_custom_minimum_size(Vector2(LINE_LENGTH * TEXT_WIDTH, (line_count * TEXT_HEIGHT) + HEADER_SIZE + FOOTER_SIZE))

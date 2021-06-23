extends MessagePanel
# Displays m.room.message in a message-box.


onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func _set_message_content():
	body = (
		"{body}".format(event.content)
	)
	
	# We skip the @ so people get unique colors.
	if event.sender.length() >= 4:
		red = event.sender.ord_at(1) * 2
		green = event.sender.ord_at(2) * 2
		blue = event.sender.ord_at(3) * 2
		sender_color = Color8(red, green, blue).to_html()

	sender_message = "[color=#%s]%s[/color]" % [sender_color, event.sender]


func _ready():
	_print_and_check(sender_name, sender_message)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)

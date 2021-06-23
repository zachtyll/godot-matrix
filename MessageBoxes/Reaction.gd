extends MessagePanel
# Displays m.room.reaction in a message-box.
# TODO: Make this show ontop of the box reacted to.


onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func _set_message_content() -> void:
	sender_message = "Implement reaction:"
	body = "[center]{content}[/center]".format(event)


func _ready():
	_print_and_check(sender_name, sender_message)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)

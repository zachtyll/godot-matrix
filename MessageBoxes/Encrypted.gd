extends MessagePanel
# Displays m.room.encrypted in a message-box.


onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


# TODO : Figure out how to solve decryption.
#	Maybe this shouldn't even be decrypted?
#	Spec is a little unclear.
func _set_message_content() -> void:
	body = "[center]This message is encrypted.[/center]"


func _ready():
	_print_and_check(sender_name, sender_message)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)

extends MessagePanel
# Displays m.room.guest_access in a message-box.


onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func set_message_content() -> void:
	sender_message = "Guest Access set to:"
	body = (
		"[center]{guest_access}![/center]".format(event.content)
	)


func _print_and_check(label : RichTextLabel, message : String) -> void:
	var err := label.append_bbcode(message)
	if err:
		push_error("BBCode failed with error: %s" % err)


func _ready():
	_print_and_check(sender_name, sender_message)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)

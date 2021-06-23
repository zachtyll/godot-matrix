extends MessagePanel
# Displays m.room.member in a message-box.


onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func _set_message_content() -> void:
	sender_message = ""
	body += "[center]"
	body += (
		"{displayname} {membership}".format(event.content)
		)
	if event.content.has("room_alias_name"):
		body += " {room_alias_name}.[/center]".format(event.content)
	else:
		body += "[/center]"
	
	# Humanize string.
	if "join" in body:
		body = body.replace("join", "joined")
	elif "leave" in body:
		body = body.replace("leave", "left")
	elif "invite" in body:
		body = body.replace("invite", "got an invite")
	else:
		pass


func _ready():
	_print_and_check(sender_name, sender_message)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)

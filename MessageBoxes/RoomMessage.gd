extends MessagePanel
# Displays m.room.message in a message-box.


const url_regex := "([\\w+]+\\:\\/\\/)?([\\w\\d-]+\\.)*[\\w-]+[\\.\\:]\\w+([\\/\\?\\=\\&\\#\\.]?[\\w-]+)*\\/?"

var preview_url := ""

onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel


func _set_message_content():
	body = (
		"{body}".format(event.content)
	)
	
	# Underline URL:s
	var regex = RegEx.new()
	regex.compile(url_regex)
	for result in regex.search_all(body):
		if  result:
#			body.erase(result.get_start(), result.get_string().length())
			body = body.insert(
				result.get_start(),
				" AAAA "
#				"[url={%s}]%s[/url] " % [result.get_string(), result.get_string()]
			)
#			body_url = body.replace(
#				 result.get_string(),
#				"[url={%s}%s]%s[/url]" % [result.get_string(), url_num, result.get_string()]
#			)

#	for word in word_list:
#		print(word)
#		var result = regex.search(word)
#		if result:
#			body = body.replace(
#				result.get_string(),
#				"[url={%s}]%s[/url]" % [word, word]
#			)
#			print(body)
		
	# We skip the @ so people get more unique colors.
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


# If the user clicks a URL, we open a browser.
func _on_MessageBody_meta_clicked(meta : String):
	# Erase {} around URL.
	meta.erase(0, 1)
	meta.erase(meta.length() -1, 1)
	var url_err := OS.shell_open(meta)
	if url_err:
		push_warning("URL ERROR: %s" % url_err)

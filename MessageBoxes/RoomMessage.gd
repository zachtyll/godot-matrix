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
	
	var previous_match := 0
	var string_index := 0
	
	var url_array := []
	
	for result in regex.search_all(body):
		if result and url_array.count(result.get_string()) == 0:
#			print("Result: %s | Array: %s" % [result.get_string(), url_array])
			url_array.append(result.get_string())
#			string_index = body.find(result.get_string(), previous_match)
#			previous_match = string_index + result.get_string().length()
#			var bbc_url = "(url=%s)" % result.get_string()
#
#			body = body.insert(string_index, bbc_url)
#			body = body.insert(
#				string_index
#				+ bbc_url.length()
#				+ result.get_string().length(),
#				"(/url)"
	print(url_array)
	for url in url_array:
		body = body.replace(url, "(url=%s)%s(/url)" % [url, url])

		
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
	var url_err := OS.shell_open(meta)
	if url_err:
		push_warning("URL ERROR: %s" % url_err)

extends MessagePanel
# Displays m.room.message in a message-box.


const url_regex := "([\\w+]+\\:\\/\\/)?([\\w\\d-]+\\.)*[\\w-]+[\\.\\:]\\w+([\\/\\?\\=\\&\\#\\.]?[\\w-]+)*\\/?"

var preview_url := ""
var texture
var image_data := {}

onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MessageBody as RichTextLabel
onready var preview := $Padding/VBoxContainer/Preview

# If the user clicks a URL, we open a browser.
func _on_MessageBody_meta_clicked(meta : String):
	var url_err := OS.shell_open(meta)
	if url_err:
		push_warning("URL ERROR: %s" % url_err)


# Sets message content for m.text type.
func _set_message_content():
	body = (
		"{body}".format(event.content)
	)
	
	# Underline URL:s
	var regex = RegEx.new()
	var url_array := []
	regex.compile(url_regex)

	for result in regex.search_all(body):
		if result and url_array.count(result.get_string()) == 0:
			url_array.append(result.get_string())
	for url in url_array:
		body = body.replace(url, "[url=%s]%s[/url]" % [url, url])
	if not url_array.empty():
		preview_url = url_array.front()
	

	# We skip the @ so people get more unique colors.
	if event.sender.length() >= 4:
		red = event.sender.ord_at(1) * 2
		green = event.sender.ord_at(2) * 2
		blue = event.sender.ord_at(3) * 2
		sender_color = Color8(red, green, blue).to_html()

	sender_message = "[color=#%s]%s[/color]" % [sender_color, event.sender]


func _adjust_for_image() -> void:
	if image_data.has("og:image:height"):
#		print("Image height is: %s" % str(image_data["og:image:height"] / 2))
		set_custom_minimum_size(Vector2(LINE_LENGTH * TEXT_WIDTH, (line_count * TEXT_HEIGHT) + HEADER_SIZE + FOOTER_SIZE + (image_data["og:image:height"] / 2)))


# This function is a little broken.
# The preview is async, so when we delete instances of self,
# we get an error due to yielding in a deleted/freed node.
func _add_preview_image() -> void:
	if not preview_url.matchn("http*"):
		pass
	else:
		var image_data = yield(GodotMatrix.preview_url(preview_url.http_escape()), "completed")
		
		if image_data.has("error"):
			print("Error: {error}".format(image_data))
		elif image_data.has("og:image"):
#			var texture = GodotMatrix.thumbnail(image_data["og:image"], 64, 64)
			var response = yield(GodotMatrix.thumbnail(image_data["og:image"], 64, 64), "completed")
			if response is Dictionary:
				print(response["error"])
			else:
				preview.texture = response
				preview.show()
	_adjust_for_image()


func _ready():
	_add_preview_image()
	_print_and_check(sender_name, sender_message)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)


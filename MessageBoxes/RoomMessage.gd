extends MessagePanel
# Displays m.room.message in a message-box.


const url_regex := "([\\w+]+\\:\\/\\/)?([\\w\\d-]+\\.)*[\\w-]+[\\.\\:]\\w+([\\/\\?\\=\\&\\#\\.]?[\\w-]+)*\\/?"

var preview_url := ""
var texture
var preview_data := {}

onready var sender_name := $Padding/VBoxContainer/HBoxContainer/SenderName as RichTextLabel
onready var time_stamp_text := $Padding/VBoxContainer/HBoxContainer/TimeStamp as RichTextLabel
onready var message_body := $Padding/VBoxContainer/MarginContainer/MessageBody as RichTextLabel
onready var preview_image := $Padding/VBoxContainer/LinkPreview/Preview as TextureRect
onready var preview_header := $Padding/VBoxContainer/LinkPreview/VBoxContainer/Header as RichTextLabel
onready var preview_body := $Padding/VBoxContainer/LinkPreview/VBoxContainer/Body as RichTextLabel


# If the user clicks a URL, we open a browser.
func _on_meta_clicked(meta : String):
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


# TODO: Improve layout.
func _adjust_for_image() -> void:
	if preview_data.has("og:image:height"):
#		print("Image height is: %s" % str(preview_data["og:image:height"] / 2))
		set_custom_minimum_size(Vector2(LINE_LENGTH * TEXT_WIDTH, (line_count * TEXT_HEIGHT) + HEADER_SIZE + FOOTER_SIZE + (preview_data["og:image:height"] / 4)))


# This function is a little broken.
# The preview is async, so when we delete instances of self,
# we get an error due to yielding in a deleted/freed node.
func _add_preview() -> void:
	if not preview_url.matchn("http*"):
		pass
	else:
		preview_data = yield(GodotMatrix.preview_url(preview_url.http_escape()), "completed")
		
		if preview_data.has("error"):
			print("Error: {error}".format(preview_data))
			return
		# Set preview image
		elif preview_data.has("og:image"):
			var response = yield(GodotMatrix.thumbnail(preview_data["og:image"]), "completed")
			if response is Dictionary:
				print(response["error"])
			else:
				_adjust_for_image()
				preview_image.texture = response
				preview_image.show()
		
		# Set title and desc.
		if preview_data.has("og:site_name"):
			var message = [preview_data["og:url"], preview_data["og:title"], preview_data["og:site_name"]]
			var _err = preview_header.append_bbcode(("[url=%s]%s[/url] \n-%s") % message)
			
		if preview_data.has("og:description") and not preview_data["og:description"] == null:
			var message = preview_data["og:description"]
			var _err = preview_body.append_bbcode(message)


func _ready():
	_add_preview()
	_print_and_check(sender_name, sender_message)
	_print_and_check(time_stamp_text, time_stamp)
	_print_and_check(message_body, body)

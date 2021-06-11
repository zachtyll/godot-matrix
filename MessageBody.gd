extends RichTextLabel

const HEADER_SIZE := 50
const TEXT_SIZE := 16

export(String) var message


onready var parent := owner as Panel

func _ready():
	_print_bbcode_message(message)
	_print_bbcode_message("END OF MESSAGE")
	
	parent.set_custom_minimum_size(Vector2(0, (get_line_count() * TEXT_SIZE) + HEADER_SIZE))


func _print_bbcode_message(message : String):
	var word_array := message.split(" ")
	var word_count := 0
	for word in word_array:
		word_count += 1
		append_bbcode(word)
		append_bbcode(" ")
#		print(word.right(word.length() - 1))
		if word.right(word.length() - 1) == ".":
#			word_array.insert(word_array.append_array()
			newline()
		if word_count >= 10:#parent.get_rect().size.x:
			word_count = 0
			newline()
	
	print(get_line_count())
	print(get_size())

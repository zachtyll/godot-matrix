extends RichTextLabel

func print_bbcode_message(message : String):
	var word_array := message.split(" ")
	var word_count := 0
	for word in word_array:
		word_count += 1
# warning-ignore:return_value_discarded
		append_bbcode(word)
# warning-ignore:return_value_discarded
		append_bbcode(" ")
		if word.right(word.length() - 1) == ".":
#			word_array.insert(word_array.append_array()
			newline()
		if word_count >= 10:#parent.get_rect().size.x:
			word_count = 0
			newline()
	newline()

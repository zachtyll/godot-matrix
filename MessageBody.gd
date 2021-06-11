extends RichTextLabel

var custom_line_count := 0


#func print_bbcode_message(message : String):
##	var word_array := message.split(" ")
##	var line_adjusted_message := ""
#	var word_count := 0
##	print(word_array)
##	for word in word_array:
##		word_count += 1
##		line_adjusted_message += word
##		line_adjusted_message += " "
##		print(line_adjusted_message)
##		if word.right(word.length() - 1) == ".":
##			print("Adding " + str(line_adjusted_message) + " to message_box")
##			append_bbcode(line_adjusted_message)
##			newline()
##			line_adjusted_message = ""
##		if word_count >= 10:
##			word_count = 0
##			append_bbcode(line_adjusted_message)
##			newline()
##			line_adjusted_message = ""
##	newline()
#
#	for test in message:
#		word_count += 1
#		if word_count >= 100:
#			word_count = 0
#			var closest_gap = message.rfindn(" ", word_count)
#			message.insert(closest_gap, "\n")
#			custom_line_count += 1
#	append_bbcode(message)

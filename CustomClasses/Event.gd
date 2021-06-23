class_name Event
extends Node
# Model for a Matrix message event.

var content = {}
var origin_server_ts = 0
var sender = ""
var state_key = ""
var type = ""
var unsigned = {
				age = 0,
			}
var event_id = ""


func _init(event : Dictionary):
	print(JSON.print(event, "\t"))
	content = get_content(event)
	origin_server_ts = get_origin_server_ts(event)
	sender = get_sender(event)
	state_key = get_state_key(event)
	type = get_type(event)
	unsigned = get_unsigned(event)
	event_id = get_event_id(event)


func get_content(event) -> Dictionary:
	if event.has("content"):
		return event["content"]
	else:
		return {}


func get_origin_server_ts(event) -> int:
	if event.has("origin_server_ts"):
		return event["origin_server_ts"]
	else:
		return -1


func get_sender(event) -> String:
	if event.has("sender"):
		return event["sender"]
	else:
		return ""


func get_state_key(event) -> String:
	if event.has("state_key"):
		return event["state_key"]
	else:
		return ""


func get_type(event) -> String:
	if event.has("type"):
		return event["type"]
	else:
		return ""


func get_unsigned(event) -> Dictionary:
	if event.has("unsigned"):
		return event["unsigned"]
	else:
		return {}


func get_event_id(event) -> String:
	if event.has("event_id"):
		return event["event_id"]
	else:
		return ""

class_name RAMStorage
extends RefCounted

var data = {}

func initialize():
	data.clear()

func store(key, value):
	data[key] = value
	return true

func retrieve(key):
	if key in data:
		return data[key]
	return null

func process_outgoing_data(data_payload):
	# Just pass through for RAM storage
	return data_payload

func process_incoming_data(data_payload):
	# Just pass through for RAM storage
	return data_payload

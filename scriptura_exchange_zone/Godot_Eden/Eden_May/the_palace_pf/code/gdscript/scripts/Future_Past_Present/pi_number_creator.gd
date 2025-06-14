# pi_number_creator.gd
extends Node

# Path to the pi_digits.txt file
var pi_file_path = "res://pi_digits.txt"

# Dictionary to store the arrays
var pi_dictionary = {}

func _ready():
	load_pi_digits()

func load_pi_digits():
	if FileAccess.file_exists(pi_file_path):
		var file = FileAccess.open(pi_file_path, FileAccess.READ)
		if file:
			var pi_digits = file.get_as_text()
			file.close()
			process_pi_digits(pi_digits)
			save_pi_dictionary()  # Save the dictionary after processing
		else:
			print("Failed to open the Pi digits file!")
	else:
		print("Pi digits file not found!")

func process_pi_digits(pi_digits: String):
	var chunk_size = 10
	var array_size = 10
	var total_chunks = pi_digits.length() / chunk_size
	
	for i in range(0, total_chunks, array_size):
		var key = "pi_%d" % (i / array_size)
		var pi_array = []
		
		for j in range(array_size):
			var start_index = (i + j) * chunk_size
			var end_index = start_index + chunk_size
			if end_index <= pi_digits.length():
				var chunk = pi_digits.substr(start_index, chunk_size)
				pi_array.append(chunk)
		
		if pi_array.size() == array_size:
			pi_dictionary[key] = pi_array
	
	print("Pi Dictionary: ", pi_dictionary)

func save_pi_dictionary():
	var file_content = []
	
	# Convert the dictionary into a format suitable for saving
	for key in pi_dictionary:
		file_content.append(key + ": " + str(pi_dictionary[key]))
	
	# Save the file to the res:// directory
	file_creation(file_content, "res://", "pi_dictionary")

# Function to create and save the file
func file_creation(file_content, path_for_file, name_for_file):
	var file = FileAccess.open(path_for_file + "/" + name_for_file + ".txt", FileAccess.WRITE)
	if file:
		for line in file_content:
			file.store_line(line)  # Store each line in the file
		print("File saved successfully at: ", path_for_file + "/" + name_for_file + ".txt")
	else:
		print("Failed to create or write to the file!")

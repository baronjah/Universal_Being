@tool
extends Node

# Romaji syllables mapping
var romaji = {
	1: 'a', 2: 'i', 3: 'u', 4: 'e', 5: 'o',
	6: 'ka', 7: 'ki', 8: 'ku', 9: 'ke', 10: 'ko',
	11: 'sa', 12: 'shi', 13: 'su', 14: 'se', 15: 'so',
	16: 'ta', 17: 'chi', 18: 'tsu', 19: 'te', 20: 'to',
	21: 'na', 22: 'ni', 23: 'nu', 24: 'ne', 25: 'no',
	26: 'ha', 27: 'hi', 28: 'fu', 29: 'he', 30: 'ho',
	31: 'ma', 32: 'mi', 33: 'mu', 34: 'me', 35: 'mo',
	36: 'ya', 37: 'yu', 38: 'yo', 39: 'ra', 40: 'ri',
	41: 'ru', 42: 're', 43: 'ro', 44: 'wa', 45: 'wo', 46: 'n'
}

func _ready():
	var word_length = 5  # for example, generate a word with 5 syllables
	var random_word = generate_random_word(word_length)
	print(random_word)

func _process(delta):
	pass
	#var word_length = randi() % 7 + 3
	#var random_word = generate_random_word(word_length)
	#print(random_word)
	
# Function to generate a random word with specified length
func generate_random_word(length: int) -> String:
	var word = ""
	for i in range(length):
		var num = randi() % 46 + 1  # random number between 1 and 46
		word += romaji[num]
	return word

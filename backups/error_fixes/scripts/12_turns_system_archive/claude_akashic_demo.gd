extends Node

# Demo script for Claude Akashic Bridge
# This script demonstrates how to use the Claude Akashic Bridge to store and retrieve data 
# from the Akashic Records and implement the "firewall of files" functionality

var bridge = null
var word_counter = 0

func _ready():
	# Initialize the bridge
	bridge = ClaudeAkashicBridge.new()
	add_child(bridge)
	
	# Connect signals
	bridge.connect("word_stored", self, "_on_word_stored")
	bridge.connect("word_rejected", self, "_on_word_rejected")
	bridge.connect("gate_status_changed", self, "_on_gate_status_changed")
	bridge.connect("wish_updated", self, "_on_wish_updated")
	bridge.connect("firewall_breached", self, "_on_firewall_breached")
	
	# Print initial status
	print_status()
	
	# Wait a moment for initialization
	yield(get_tree().create_timer(1.0), "timeout")
	
	# Run demo operations
	run_demo()

func run_demo():
	print("\n=== CLAUDE AKASHIC BRIDGE DEMO ===\n")
	
	# 1. Store a word
	print("1. Storing a word...")
	var result = bridge.store_word("consciousness", 65, {
		"origin": "claude_bridge_demo",
		"dimension": 3,
		"category": "metaphysical"
	})
	print("   Result: " + str(result))
	
	# 2. Store a batch of words
	print("\n2. Storing a batch of words...")
	var words_batch = [
		{"word": "reality", "power": 70, "metadata": {"category": "fundamental"}},
		{"word": "creation", "power": 85, "metadata": {"category": "divine"}},
		{"word": "harmony", "power": 60, "metadata": {"category": "balance"}}
	]
	var batch_result = bridge.store_words_batch(words_batch)
	print("   Batch result: " + str(batch_result))
	
	# 3. Update a wish
	print("\n3. Updating a wish...")
	var wish_result = bridge.update_wish("dream_manifestation", "processing", {
		"progress": 0.5,
		"priority": "high",
		"expected_completion": OS.get_unix_time() + 86400
	})
	print("   Wish update result: " + str(wish_result))
	
	# 4. Create a protected record
	print("\n4. Creating a protected record...")
	var record = bridge.create_protected_record("document", "This is a protected document that serves as a test for the Claude Akashic Bridge system.", {
		"title": "Test Document",
		"author": "Claude",
		"keywords": ["test", "protection", "akashic"]
	})
	print("   Record creation result: " + str(record))
	
	# 5. Query the Akashic Records
	print("\n5. Querying the Akashic Records...")
	var query_result = bridge.query_akashic_records("consciousness", {
		"use_claude": true,
		"max_results": 5,
		"include_metadata": true
	})
	print("   Query result: " + str(query_result))
	
	# 6. Test dimensional gates
	print("\n6. Testing dimensional gates...")
	print("   Opening gate_0: " + str(bridge.open_gate("gate_0")))
	print("   Opening gate_1: " + str(bridge.open_gate("gate_1")))
	print("   Opening gate_2: " + str(bridge.open_gate("gate_2")))
	
	# 7. Update firewall settings
	print("\n7. Updating firewall settings...")
	var firewall_result = bridge.update_firewall("divine", {
		"dimension_access": 5,
		"gates": {"gate_0": true, "gate_1": true, "gate_2": true}
	})
	print("   Firewall update result: " + str(firewall_result))
	
	# 8. Test Claude error handling
	print("\n8. Testing Claude error handling...")
	var error_result = bridge.handle_claude_error("Token limit exceeded", {
		"model": "claude-3-5-sonnet",
		"request_size": 15000
	})
	print("   Error recovery result: " + str(error_result))
	
	# 9. Test word rejection by firewall
	print("\n9. Testing firewall rejection...")
	var suspicious_word_result = bridge.store_word("exec rm -rf", 90, {
		"origin": "test",
		"dimension": 10
	})
	print("   Suspicious word storage result: " + str(suspicious_word_result))
	
	# Final status
	print("\nFinal system status:")
	print_status()

func print_status():
	var status = bridge.get_status()
	print("\n=== CLAUDE AKASHIC BRIDGE STATUS ===")
	print("Akashic Connected: " + str(status.akashic_connected))
	print("Claude Connected: " + str(status.claude_connected))
	print("Firewall Active: " + str(status.firewall_active))
	print("Firewall Level: " + status.firewall_level)
	print("Dimension Access: " + str(status.dimension_access))
	print("Gates Status: " + str(status.gates))
	print("Error Count: " + str(status.errors))
	print("Recovery Points: " + str(status.recovery_points))
	print("======================================\n")

# Signal callbacks
func _on_word_stored(word, power, metadata):
	print("SIGNAL: Word stored - " + word + " (power: " + str(power) + ")")
	word_counter += 1

func _on_word_rejected(word, reason):
	print("SIGNAL: Word rejected - " + word + " (reason: " + reason + ")")

func _on_gate_status_changed(gate_name, status):
	print("SIGNAL: Gate status changed - " + gate_name + " is now " + ("open" if status else "closed"))

func _on_wish_updated(wish_id, new_status):
	print("SIGNAL: Wish updated - " + wish_id + " -> " + new_status)

func _on_firewall_breached(breach_info):
	print("SIGNAL: FIREWALL BREACH - " + breach_info.type + ": " + breach_info.message)
	
	# In a real system, this would trigger security measures
	if breach_info.type == "ACCESS_DENIED":
		print("   Security measure: Increasing firewall protection...")
		# Simulate increasing security
		bridge.update_firewall("enhanced")
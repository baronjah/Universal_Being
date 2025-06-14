# DataBus.gd

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
# data bus so pathways for informations flow
extends Node

var connections = {}  # Stores which nodes are connected to which


#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#


func register_node(node, identifier):
	if identifier not in connections:
		connections[identifier] = {"inputs": [], "outputs": []}

func connect_nodes(sender_id, receiver_id):
	# Ensure both nodes are registered
	if sender_id in connections and receiver_id in connections:
		connections[sender_id]["outputs"].append(receiver_id)
		connections[receiver_id]["inputs"].append(sender_id)

func send_signal(sender_id, action):
	if sender_id in connections:
		for receiver_id in connections[sender_id]["outputs"]:
			if receiver_id in connections:
				# Assuming each node has a method to receive actions
				connections[receiver_id].receive_action(action)

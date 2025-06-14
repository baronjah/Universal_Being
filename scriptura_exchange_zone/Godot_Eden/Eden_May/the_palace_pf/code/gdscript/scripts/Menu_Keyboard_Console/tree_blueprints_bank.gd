# tree_blueprints_bank.gd
class_name TreeBlueprints #TreeBlueprints.SCENE_TREE_BLUEPRINT BRANCH_BLUEPRINT

const SCENE_TREE_BLUEPRINT = {
	"main_root": {
		"name": [],
		"type": [],
		"jsh_type": [],
		"branches": {},
		"status": "pending",  # pending/processing/complete, now i have pending, active, disabled
		"metadata": {
			"creation_time": 0,
			"priority": 0
		}
	}
}

const BRANCH_BLUEPRINT = {
	"name": [],
	"type": [],
	"jsh_type": [],
	"children": {},
	"parent": [],
	"status": "pending",
	"metadata": {
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"creation_order": 0
	}
}


# the two point o, jsh tree
const JSH_TREE = {
	"name": "",  # Root node name
	"type": "",  # Node type
	"status": "pending",
	"node": null,  # Node reference
	"nodes": {},  # All nodes by path
	"metadata": {
		"creation_time": 0,
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"collisions": [],  # Track collision related nodes
		"groups": [],
		"parent_path": "",
		"full_path": "",
		"creation_order": 0
	}
}

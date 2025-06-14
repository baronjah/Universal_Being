#OrbitStabilizer.gd in new test scene
@tool
extends \2

var star_position_basis: Basis# = Basis.IDENTITY

func _process(delta):
	global_transform.basis = star_position_basis

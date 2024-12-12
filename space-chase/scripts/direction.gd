extends Node

enum Facing {
	LEFT,
	RIGHT,
}

func get_opposite_faing(facing: Facing) -> Facing:
	if facing == Facing.LEFT:
		return Facing.RIGHT
	else:
		return Facing.LEFT


func get_sign_factor(facing: Facing) -> float:
	if facing == Facing.RIGHT:
		return 1.0
	else:
		return -1.0


func flip_horizontal(target: Node2D, facing: Facing) -> void:
	if facing == Facing.RIGHT:
		target.rotation_degrees = 0
		target.scale.y = abs(target.scale.y)
	else:
		target.rotation_degrees = 180
		target.scale.y = -1.0 * abs(target.scale.y)

class_name DashTrail
extends Line2D

# Should be a child of the player

@export var length : = 10

var offset : = Vector2.ZERO

@onready var player: Player = get_parent()


func _ready() -> void:
	offset = position
	top_level = true
	z_index = -1 # Render behind the player


func _physics_process(_delta: float) -> void:
	global_position = Vector2.ZERO

	if player.is_dashing:
		var point : = player.global_position + offset
		add_point(point, 0)
		if get_point_count() > length:
			remove_point(get_point_count() - 1)
	elif get_point_count() > 0:
		remove_point(get_point_count() - 1)

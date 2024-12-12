class_name ConditionalTrail
extends Line2D

# Should be direct child of Node2D

@export var length : = 10

var draw_trail: bool = false
var offset : = Vector2.ZERO

@onready var parent: Node2D = get_parent()


func _ready() -> void:
	offset = position
	top_level = true
	z_index = -1 # Render behind the parent


func _physics_process(_delta: float) -> void:
	global_position = Vector2.ZERO

	if draw_trail:
		var point : = parent.global_position + offset
		add_point(point, 0)
		if get_point_count() > length:
			remove_point(get_point_count() - 1)
	elif get_point_count() > 0:
		remove_point(get_point_count() - 1)

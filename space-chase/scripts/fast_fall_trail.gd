class_name FastFallTrail
extends ConditionalTrail

@onready var player: Player = get_parent() as Player


func _physics_process(_delta: float) -> void:
	draw_trail = player.is_fast_falling
	super(_delta)

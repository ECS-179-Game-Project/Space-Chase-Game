class_name DashTrail
extends ConditionalTrail

@onready var player: Player = get_parent() as Player


func _physics_process(_delta: float) -> void:
	draw_trail = player.is_dashing
	super(_delta)

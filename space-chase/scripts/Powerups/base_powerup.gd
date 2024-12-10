class_name BasePowerup
extends Area2D

"""
Custom powerup types should extend this class
Make sure each powerup type has its own scene

If player collects it, gives the player energy (through game state manager)
Gives abilities to the player (through powerup manager)
"""

const HOVER_AMPLITUDE:float = 5.0
const HOVER_SPEED: float = 2.0

@export var duration: float = 15.0  
@export var type: PowerupManager.PowerupType

var _hover_time: float = 0.0
var _original_pos: Vector2


func _init() -> void:
	set_collision_mask_value(3, true) # Detect hurtboxes (specifically players)
	area_entered.connect(_on_hurtbox_entered)
	

func _ready() -> void:
	_original_pos = global_position


func _physics_process(delta: float) -> void:
	_hover_time += HOVER_SPEED * delta
	global_position.y = _original_pos.y + HOVER_AMPLITUDE * cos(_hover_time)


func _on_hurtbox_entered(hurtbox: HurtBox) -> void:
	var target := hurtbox.owner

	if target is Player and (not target.is_held) and (not target.is_ghost):
		PowerupManager.apply_powerup(type, target, duration)
		queue_free()  # Destroy the power-up after use

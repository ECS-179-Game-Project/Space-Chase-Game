class_name BasePowerup
extends Area2D

"""
Custom powerup types should extend this class
Make sure each powerup type has its own scene

If player collects it, gives the player energy (through game state manager)
Gives abilities to the player (through powerup manager)
"""

@export var duration: float = 15.0  
@export var type: PowerupManager.PowerupType

func _init() -> void:
	set_collision_mask_value(3, true) # Detect hurtboxes (specifically players)
	area_entered.connect(_on_hurtbox_entered)


func _on_hurtbox_entered(hurtbox: HurtBox) -> void:
	var target := hurtbox.owner

	if target is Player and (not target.is_held) and (not target.is_ghost):
		PowerupManager.apply_powerup(type, target, duration)
		queue_free()  # Destroy the power-up after use

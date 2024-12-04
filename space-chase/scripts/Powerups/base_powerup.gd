
extends CharacterBody2D

"""
Custom powerup types should extend this class
Make sure each powerup type has its own scene

If player collects it, gives the player energy (through game state manager)
Gives abilities to the player (through powerup manager)
"""

@export var duration: float = 5.0  
@export var type: PowerupManager.PowerupType

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		PowerupManager.apply_powerup(type, body, duration)
		queue_free()  # Destroy the power-up after use


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.

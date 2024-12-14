class_name HitBox
extends Area2D

"""
Everything in the game is instakill
"""
func _init() -> void:
	set_collision_layer_value(4, true)
	set_collision_mask_value(3, true) # Detect hurtboxes
	area_entered.connect(_on_hurtbox_entered)


func _on_hurtbox_entered(hurtbox: Area2D) -> void:
	if hurtbox is HurtBox:
		var target := hurtbox.owner
		
		if target.has_method("instakill"):
			target.instakill()

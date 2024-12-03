class_name HurtBox
extends Area2D

@onready var hurt_owner: Player = get_parent()


func _init() -> void:
	set_collision_layer_value(3, true)
	set_collision_mask_value(3, true) # Detect hurtboxes
	area_entered.connect(_on_hurtbox_entered)


func _on_hurtbox_entered(hurtbox:HurtBox) -> void:
	var target := hurtbox.owner
	
	if target is Player and target.is_ghost:
		return
	
	if hurt_owner.is_dashing and target.has_method("dash_stun"):
		target.dash_stun(hurt_owner.facing)

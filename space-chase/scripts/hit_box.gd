class_name HitBox
extends Area2D

"""
Everything in the game is instakill
"""
func _init() -> void:
	set_collision_layer_value(4, true)
	set_collision_mask_value(3, true) # Detect hurtboxes
	area_entered.connect(_on_hurtbox_entered)


func _on_hurtbox_entered(hurtbox: HurtBox) -> void:
		
	var target := hurtbox.owner
	#current_energy = game_state_manager.get_player_energy(PlayerID.PLAYER_1)
	#adjusted_energy = current_energy * 0.75
	
	if target.has_method("instakill"):
		target.instakill()

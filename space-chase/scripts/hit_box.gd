class_name HitBox
extends Area2D

"""
Everything in the game is instakill
"""

func _init() -> void:
	collision_layer = 0
	collision_mask = 8
	area_entered.connect(_on_hurtbox_entered)


func _on_hurtbox_entered(hurtbox: HurtBox) -> void:
	var target := hurtbox.owner
	
	if target.has_method("instakill"):
		target.instakill()

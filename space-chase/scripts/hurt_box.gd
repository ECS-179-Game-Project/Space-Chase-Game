class_name HurtBox
extends Area2D

func _init() -> void:
	collision_layer = 8
	collision_mask = 0
	area_entered.connect(_on_hitbox_entered)


func _on_hitbox_entered(hitbox:HitBox) -> void:
	# No need for any code here, HurtBox is simply used for detection by HitBox and GrabBox
	pass

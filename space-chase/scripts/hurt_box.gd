class_name HurtBox
extends Area2D

#  NOTE: No need for hurt box since hit box handles all damage dealing

var damage: int

func _init() -> void:
	collision_layer = 8
	collision_mask = 0
	area_entered.connect(_on_area_entered)


func _on_area_entered(hitbox:HitBox) -> void:
	# No need for any code here, HurtBox is simply used for detection by HitBox
	pass

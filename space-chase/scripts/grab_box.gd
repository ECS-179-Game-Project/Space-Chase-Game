class_name GrabBox
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 8
	area_entered.connect(_on_grabbox_entered)
	area_entered.connect(_on_hurtbox_entered)


func _on_grabbox_entered(grabbox: GrabBox) -> void:
	var target := grabbox.owner
	
	if target.has_method("grab_tech"):
		target.grab_tech()


func _on_hurtbox_entered(hurtbox: HurtBox) -> void:
	var target := hurtbox.owner
	
	if target.has_method("got_grabbed"):
		target.got_grabbed()

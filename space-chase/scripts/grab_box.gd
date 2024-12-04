class_name GrabBox
extends Area2D

@onready var grab_owner: Player = get_parent()


func _init() -> void:
	set_collision_layer_value(5, true)
	set_collision_mask_value(3, true) # Detect hurtboxes
	set_collision_mask_value(5, true) # Detect grabboxes
	area_entered.connect(_on_grabbox_entered)
	area_entered.connect(_on_hurtbox_entered)


func _on_grabbox_entered(grabbox: GrabBox) -> void:
	var target := grabbox.owner
	
	if target.has_method("grab_tech"):
		target.grab_tech()
		grab_owner.grab_tech()


func _on_hurtbox_entered(hurtbox: HurtBox) -> void:
	var target := hurtbox.owner
	
	if target is Player and target.is_ghost:
		return
	
	if grab_owner != target and target.has_method("got_grabbed"):
		target.got_grabbed()
		grab_owner.hold(target)

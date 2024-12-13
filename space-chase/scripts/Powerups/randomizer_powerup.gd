extends BasePowerup

# Preloaded power-up scenes
var powerup_scenes = [
	preload("res://scenes/powerups/energy_gain_powerup.tscn"),
	preload("res://scenes/powerups/get_big_powerup.tscn"),
	preload("res://scenes/powerups/get_small_powerup.tscn"),
	preload("res://scenes/powerups/jump_powerup.tscn"),
	preload("res://scenes/powerups/speed_powerup.tscn")
]

func _ready() -> void:
	$AnimationPlayer.play("rotatin")
	super()

func _on_hurtbox_entered(hurtbox: HurtBox) -> void:
	var target = hurtbox.owner

	if target is Player and not target.is_held and not target.is_ghost:
		_spawn_powerup(target)
		# Queue this node for deletion after the power-up logic is handled
		call_deferred("queue_free")

func _spawn_powerup(player:Player) -> void:
	# Select a random power-up scene
	var random_powerup_scene = powerup_scenes[randi() % powerup_scenes.size()]

	# Instance the power-up and apply its effect
	var powerup_instance = random_powerup_scene.instantiate()
	
	# Add the powerup close to the player
	player.add_child(powerup_instance)  

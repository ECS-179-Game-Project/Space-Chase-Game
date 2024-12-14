class_name EnergyGenerator
extends Node2D

@export var spawn_radius: float = 25.0
@export var spawn_time: float = 5.0
@export var wait_for_final_zone: bool = false

# Preloaded power-up scene
var energy_powerup_scene = preload("res://scenes/powerups/energy_gain_powerup.tscn")

var _in_final_zone: bool = false
var _cur_time: float = 0.0


func _ready() -> void:
	GameStateManager.final_zone_entered.connect(_on_final_zone_entered)
	_cur_time = 0.0


func _process(delta: float) -> void:
	if wait_for_final_zone and (not _in_final_zone):
		return
	
	_cur_time += delta
	
	# Every 5 seconds:
	if _cur_time >= spawn_time:
		_spawn_powerup()
		_cur_time = 0.0


func _on_final_zone_entered() -> void:
	_in_final_zone = true


func _spawn_powerup() -> void:
	# Instance the power-up and apply its effect
	var energy_powerup: BasePowerup = energy_powerup_scene.instantiate()
	var angle: float = randf() * TAU
	var distance: float = randf() * spawn_radius
	var offset = distance * Vector2(cos(angle), sin(angle))
	energy_powerup.global_position = global_position + offset
	
	# Play spawn animation
	var animation_player: AnimationPlayer = energy_powerup.get_node("AnimationPlayer")
	if animation_player:
		animation_player.play("spawn")
	else:
		print("ERROR: ENERGY SPAWN ANIMATION PLAYER NOT FOUND")
	
	# Add powerup
	get_parent().add_child(energy_powerup)

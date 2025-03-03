class_name BasePowerup
extends Area2D

"""
Custom powerup types should extend this class
Make sure each powerup type has its own scene

If player collects it, gives the player energy (through game state manager)
Gives abilities to the player (through powerup manager)
"""

const HOVER_AMPLITUDE:float = 5.0
const HOVER_SPEED: float = 2.0

signal powerup_collected(type: PowerupManager.PowerupType, position: Vector2)

@export var duration: float = 10.0
@export var type: PowerupManager.PowerupType

var _hover_time: float = 0.0
var _original_pos: Vector2
var _powerup_particles: int

@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
#@onready var audio_files = {
	#PowerupManager.PowerupType.SPEED_BOOST: preload("res://assets/Sound Effects/Powerups/Getbig.ogg"),
	#PowerupManager.PowerupType.JUMP_BOOST: preload("res://assets/Sound Effects/Powerups/Getbig.ogg"),
	#PowerupManager.PowerupType.SHIELD: preload("res://assets/Sound Effects/Powerups/Getbig.ogg"),
	#PowerupManager.PowerupType.ENERGY_GAIN: preload("res://assets/Sound Effects/Powerups/Getbig.ogg"),
	#PowerupManager.PowerupType.GET_BIG: preload("res://assets/Sound Effects/Powerups/Getbig.ogg"),
	#PowerupManager.PowerupType.GET_SMALL: preload("res://assets/Sound Effects/Powerups/Getbig.ogg")
#}


func _init() -> void:
	set_collision_mask_value(3, true) # Detect hurtboxes (specifically players)
	area_entered.connect(_on_hurtbox_entered)
	_powerup_particles = Particles.load_particle("res://scenes/particles/2_powerup_particle.tscn")
	

func _ready() -> void:
	_original_pos = global_position
	

func _physics_process(delta: float) -> void:
	_hover_time += HOVER_SPEED * delta
	global_position.y = _original_pos.y + HOVER_AMPLITUDE * cos(_hover_time)


func _on_hurtbox_entered(hurtbox: Area2D) -> void:
	if hurtbox is HurtBox:
		var target := hurtbox.owner

		if target is Player and (not target.is_held) and (not target.is_ghost):
			PowerupManager.apply_powerup(type, target, duration)
			
			Particles.spawn_particle_to_world(_powerup_particles, global_position)
			emit_signal("powerup_collected", type, global_position)
			#var audio_player = AudioStreamPlayer.new()
			#add_child(audio_player)
			#audio_player.stream = preload("res://assets/Sound Effects/Powerups/Getbig.ogg")
			#audio_player.volume_db = 0
			#audio_player.play()
			#
			#sound.play()
				
			# Queue free the player after the audio finishes
			#audio_player.connect("finished", audio_player, "queue_free")
			if sound and sound.stream:
				sound.play()
				# Wait until the sound finishes before freeing the node
				sound.connect("finished", Callable(self, "_on_audio_finished"))
			else:
				queue_free()  # If no audio, free immediately


			queue_free()  # Destroy the power-up after use

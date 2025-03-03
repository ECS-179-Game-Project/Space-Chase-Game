class_name ChargingStation
extends Node2D

const CHARGE_RADIUS: float = 100.0

## Reference to the player that this charging station
## is assigned to.
@export var owner_player: Player
@export var override_chargeability: bool = false ## If true, then station is always chargeable.

var charge_ok := false ## Activation status of the charging station.

var _energy_charged: float = 0.0 ## Stored energy of the charging station.

var _charge_zone_particles: GPUParticles2D

@onready var win_threshold = GameStateManager.WINNING_THRESHOLD
@onready var charger_id = owner_player.player_id ## ID of the player that owns the charging station.
@onready var player_color = owner_player.player_color

@onready var charge_bar = $ChargeBar
@onready var charge_progress_bar = $ChargeBar/ProgressBar
@onready var particle_target_point: Vector2 = $ParticleTargetPoint.global_position

func _ready() -> void:
	charge_ok = false
	
	_charge_zone_particles = load("res://scenes/particles/1_charging_zone.tscn").instantiate()
	_charge_zone_particles.emitting = override_chargeability
	_charge_zone_particles.process_material.set("emission_ring_radius", CHARGE_RADIUS)
	_charge_zone_particles.process_material.set("emission_ring_inner_radius", CHARGE_RADIUS * 0.95)
	_charge_zone_particles.z_index = 1
	_charge_zone_particles.z_as_relative = true
	
	var zone_color = Color.from_hsv(player_color.h, 1.0, 1.0)
	charge_progress_bar.set_color(zone_color)
	print(zone_color)
	zone_color.g += 0.4
	_charge_zone_particles.process_material.set("color", zone_color)
	
	
	charge_progress_bar.value = 0
	charge_progress_bar.max_value = win_threshold
	charge_bar.visible = override_chargeability
	
	add_child(_charge_zone_particles)
	GameStateManager.final_zone_entered.connect(_on_final_zone_entered)
	GameStateManager.level_entered.connect(_on_level_entered)


func _process(delta):
	if charge_ok or override_chargeability:
		if _energy_charged >= win_threshold:
			GameStateManager.player_win.emit(charger_id)
		elif global_position.distance_to(owner_player.global_position) < CHARGE_RADIUS and owner_player.can_charge():
			GameStateManager.request_charge.emit(self, charger_id, delta)
		

func charge_energy(x: float) -> float:
	var prev_energy = _energy_charged
	
	if _energy_charged + x > win_threshold:
		_energy_charged = win_threshold
	else:
		_energy_charged += x
	
	charge_progress_bar.value = _energy_charged
	
	return prev_energy - _energy_charged
	
func get_ship_energy()-> float:
	return _energy_charged
	
func _on_final_zone_entered() -> void:
	charge_ok = true
	charge_bar.visible = true
	_charge_zone_particles.emitting = true
	GameStateManager._player_won = false


func _on_level_entered() -> void:
	charge_ok = false
	charge_bar.visible = override_chargeability
	_charge_zone_particles.emitting = false
	_energy_charged = 0.0

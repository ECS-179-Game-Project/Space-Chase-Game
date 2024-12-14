extends Node2D

const GENERATE_TIME: float = 0.1


@export var charging_station: ChargingStation

var gen_timer: Timer

@onready var _energy_particles = $EnergyParticles as TrackedParticles

func _ready() -> void:
	_set_distance()
	_energy_particles.material.set("shader_parameter/inputColor", charging_station.player_color)
	_energy_particles.emitting = false
	GameStateManager.final_zone_entered.connect(_on_final_zone_entered)
	GameStateManager.request_charge.connect(_on_request_charge)
	
	gen_timer = Timer.new()
	gen_timer.one_shot = true
	gen_timer.timeout.connect(_on_timeout)
	add_child(gen_timer)


func _on_final_zone_entered() -> void:
	_set_distance()
	

func _on_timeout() -> void:
	print(charging_station.global_position - $".".global_position)
	_energy_particles.emitting = false


func _on_request_charge(charger: ChargingStation, id: GameStateManager.PlayerID, _delta) -> void:
	
	if id == charging_station.charger_id:
		if not is_zero_approx(GameStateManager.get_player_energy(id)):
			gen_timer.start(GENERATE_TIME)
			_energy_particles.emitting = true


func _set_distance():
	var target = charging_station.particle_target_point
	target.y += 20
	_energy_particles.process_material.set("shader_parameter/target", charging_station.global_position)
	var radius = charging_station.particle_target_point.distance_to(global_position + Vector2.ONE)
	_energy_particles.process_material.set("shader_parameter/target_attraction_radius", radius)

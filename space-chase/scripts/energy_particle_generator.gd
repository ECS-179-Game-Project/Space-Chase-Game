extends Node2D

@export var charging_station: ChargingStation

@onready var _energy_particles = $EnergyParticles as TrackedParticles

func _ready() -> void:
	_energy_particles.emitting = false

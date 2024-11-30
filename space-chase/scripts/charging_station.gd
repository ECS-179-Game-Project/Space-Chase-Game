class_name ChargingStation
extends Node2D

const WIN_THRESHOLD: int = 200
const CHARGE_RADIUS: float = 50.0

## Reference to the player that this charging station
## is assigned to.
@export var owner_player: Player 

var charge_ok := false ## Activation status of the charging station.

var _energy_charged: float = 0.0 ## Stored energy of the charging station.

@onready var charger_id = owner_player ## ID of the player that owns the charging station.


func _process(delta):
	if charge_ok:
		if _energy_charged > WIN_THRESHOLD:
			GameStateManager.player_win.emit(charger_id)
		elif global_position.distance_to(owner_player.global_position) < CHARGE_RADIUS:
			GameStateManager.request_charge.emit(self, charger_id, delta)
		

func charge_energy(x: float) -> float:
	var prev_energy = _energy_charged
	
	if _energy_charged + x > WIN_THRESHOLD:
		_energy_charged = WIN_THRESHOLD
	else:
		_energy_charged += x
	
	return prev_energy - _energy_charged

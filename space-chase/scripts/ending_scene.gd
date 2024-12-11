extends Label

@onready var winner = $"."

@export var charging_station: ChargingStation
#this is untested 
func _process(delta: float) -> void:
	
	if charging_station.charge_ok:
		if charging_station._energy_charged >= charging_station.WIN_THRESHOLD:
			winner.text = "Player %d Wins" % charging_station.charger_id 
		

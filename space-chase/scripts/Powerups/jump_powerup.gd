class_name JumpPowerup
extends BasePowerup


var speedboast: float
var type

func _init(duration: float, speedboast: float) -> void:
	self.duration = duration
	self.speedboast = speedboast

func apply_power_up(player: Player) -> void:
	


func revert(player: Player) -> void:
	pass

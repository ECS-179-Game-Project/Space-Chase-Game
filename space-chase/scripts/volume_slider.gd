extends HSlider

@export_enum("Master", "SFX", "MUSIC") var bus: String

var _bus_index: int

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	_bus_index = AudioServer.get_bus_index(bus)
	

func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_mute(_bus_index, is_equal_approx(new_value, min_value))
	AudioServer.set_bus_volume_db(_bus_index, new_value)

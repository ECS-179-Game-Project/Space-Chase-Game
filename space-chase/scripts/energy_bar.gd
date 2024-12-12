@tool
class_name EnergyBar
extends Control

@export var bar_color: Color = Color.WHITE
@export var owner_player: GameStateManager.PlayerID = GameStateManager.PlayerID.PLAYER_1

@onready var energy_bar = $Texture/PlayerEnergy as ProgressBar


func _ready() -> void:
	if not Engine.is_editor_hint():
		energy_bar.max_value = GameStateManager.WINNING_THRESHOLD
		energy_bar.get_theme_stylebox("fill").set("bg_color", bar_color)


func _process(_delta) -> void:
	if Engine.is_editor_hint():
		energy_bar.get_theme_stylebox("fill").set("bg_color", bar_color)
	else:
		energy_bar.value = GameStateManager.get_player_energy(owner_player)
	

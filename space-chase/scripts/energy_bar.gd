class_name EnergyBar
extends Control

@export var bar_color: Color = Color.WHITE
@export var owner_player: GameStateManager.PlayerID = GameStateManager.PlayerID.PLAYER_1

@onready var energy_bar = $Texture/PlayerEnergy as ProgressBar


func _init():
	GameStateManager.player_ready.connect(_on_player_ready)


func _ready() -> void:
	energy_bar.max_value = GameStateManager.WINNING_THRESHOLD


func _process(_delta) -> void:
	energy_bar.value = GameStateManager.get_player_energy(owner_player)
	

func _on_player_ready(id: GameStateManager.PlayerID):
	print("fofsodfsdfsd")
	if owner_player == id:
		energy_bar.get_theme_stylebox("fill").set("bg_color",
			GameStateManager.player_colors[owner_player].lightened(0.3))
		print(GameStateManager.player_colors)

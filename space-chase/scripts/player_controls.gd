class_name PlayerControls
extends Resource

var left: String
var right: String
var up: String
var down: String
var jump: String
var grab: String
var dash: String
var control_list: Array

static var p1_control_list: Array = ["p1_left", "p1_right", "p1_up", "p1_down", "p1_jump", "p1_grab", "p1_dash"]
static var p2_control_list: Array = ["p2_left", "p2_right", "p2_up", "p2_down", "p2_jump", "p2_grab", "p2_dash"]

# Maps player id to bool which indicates if up input should also be used as jump input
static var use_up_as_jump: Dictionary = {
	GameStateManager.PlayerID.PLAYER_1: false,
	GameStateManager.PlayerID.PLAYER_2: false,
}

static var swap_controls: bool = false

# Use factory pattern to return each player's controls

static func get_p1_controls() -> PlayerControls:
	var controls = PlayerControls.new()
	controls.left = "p1_left"
	controls.right = "p1_right"
	controls.up = "p1_up"
	controls.down = "p1_down"
	controls.jump = "p1_jump"
	controls.grab = "p1_grab"
	controls.dash = "p1_dash"
	controls.control_list = p1_control_list
	return controls


static func get_p2_controls() -> PlayerControls:
	var controls = PlayerControls.new()
	controls.left = "p2_left"
	controls.right = "p2_right"
	controls.up = "p2_up"
	controls.down = "p2_down"
	controls.jump = "p2_jump"
	controls.grab = "p2_grab"
	controls.dash = "p2_dash"
	controls.control_list = p2_control_list
	return controls


func any_control_just_pressed() -> bool:
	for control in control_list:
		if Input.is_action_just_pressed(control):
			return true
	return false

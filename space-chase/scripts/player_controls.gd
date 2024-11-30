class_name PlayerControls
extends Resource

var left: String
var right: String
var up: String
var down: String
var grab: String
var dash: String

# Uses factory pattern to return each player's controls

static func get_p1_controls() -> PlayerControls:
	var controls = PlayerControls.new()
	controls.left = "p1_left"
	controls.right = "p1_right"
	controls.up = "p1_up"
	controls.down = "p1_down"
	controls.grab = "p1_grab"
	controls.dash = "p1_dash"
	return controls

static func get_p2_controls() -> PlayerControls:
	var controls = PlayerControls.new()
	controls.left = "p2_left"
	controls.right = "p2_right"
	controls.up = "p2_up"
	controls.down = "p2_down"
	controls.grab = "p2_grab"
	controls.dash = "p2_dash"
	return controls

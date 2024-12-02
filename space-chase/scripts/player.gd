class_name Player
extends CharacterBody2D

"""
Identified by player id (enum is from game state manager)
Exported variable for respective charging station
Movement mechanics
- left/right
- go down platforms
- jump
- 8 direction dash (like celeste)
Grab mechanics
- Can grab/throw the other player
- Can be grabbed/thrown by the other player (bool for grabbed)
If dies, give the other player energy (through game state manager)
If close to respective charging station, slowly charge up the station (through game state manager)
"""

enum Facing {
	LEFT,
	RIGHT,
}

## Time in seconds in which jumping is possible
## after no longer being on the floor
const COYOTE_TIME_WINDOW: float = 0.06

@export var player_id := GameStateManager.PlayerID.PLAYER_1
@export var player_color: Color = Color.BLACK
@export var speed: float = 200.0
@export var jump_force: float = 350.0
@export var max_dashes: int = 1
@export var dash_speed_factor: float = 130.0
@export var dash_time: float = 0.15
@export var ground_dash_cooldown: float = 0.7
@export_range (0, 1800) var gravity: float = 1600.0
@export var terminal_velocity: float = 400.0
@export_range (1.0, 5.0) var fast_fall_factor: float = 2.0
@export_range (0.0, 1.0) var hold_jump_gravity_reduction: float = 0.5

var facing: Facing = Facing.RIGHT
var dashes: int = max_dashes
var is_dashing: bool = false
var is_grabbing: bool = false # Currently grabbing/holding the othe player
var is_grabbed: bool = false # Currently grabbed/held by the other player
var is_fast_falling: bool = false
var is_holding_jump: bool = false

var _controls: PlayerControls # Initialized based on player_id
var _dir: Vector2 # Stores direction of 8-way input
var _dash_timer: Timer
var _ground_dash_cooldown_timer: Timer
var _coyote_timer: Timer
var _thrown_stun_delay: Timer # Timer to wait until player can move after being thrown

@onready var _main_animation_player: AnimationPlayer = $MovementAnimationPlayer
@onready var _status_animation_player: AnimationPlayer = $StatusAnimationPlayer


func _ready() -> void:
	# Set contrls based on player_id
	if player_id == GameStateManager.PlayerID.PLAYER_1:
		_controls = PlayerControls.get_p1_controls()
	elif player_id == GameStateManager.PlayerID.PLAYER_2:
		_controls = PlayerControls.get_p2_controls()
	else:
		print("ERROR: INVALID PLAYER_ID, CANNOT SET CONTROLS")
	
	# Set player color
	if has_node("Sprite2D"):
		$Sprite2D.material.set("shader_parameter/inputColor", player_color)
	
	# Initialize timers
	_dash_timer = Timer.new()
	_dash_timer.one_shot = true
	add_child(_dash_timer)
	_ground_dash_cooldown_timer = Timer.new()
	_ground_dash_cooldown_timer.one_shot = true
	add_child(_ground_dash_cooldown_timer)
	_coyote_timer = Timer.new()
	_coyote_timer.one_shot = true
	add_child(_coyote_timer)
	
	# Initialize color
	if has_node("Sprite2D"):
		$Sprite2D.material.set("shader_parameter/inputColor", player_color)


func _physics_process(delta: float) -> void:
	# Get input direction
	var horizontal_dir := Input.get_axis(_controls.left, _controls.right)
	var vertical_dir := Input.get_axis(_controls.up, _controls.down)
	_dir = Vector2(horizontal_dir, vertical_dir).normalized()
	
	_handle_facing()
	
	# Handle gravity
	if _is_in_normal_state() and (not is_on_floor()):
		var apply_gravity: float = gravity * delta
		var acting_terminal_velocity: float = terminal_velocity
		is_fast_falling = Input.is_action_pressed(_controls.down)
		is_holding_jump = Input.is_action_pressed(_controls.up) and velocity.y < 0
		if is_fast_falling:
			apply_gravity *= fast_fall_factor
			acting_terminal_velocity *= fast_fall_factor
		elif is_holding_jump:
			apply_gravity *= hold_jump_gravity_reduction
		velocity.y = min(velocity.y + apply_gravity, acting_terminal_velocity)
	else:
		is_fast_falling = false
		is_holding_jump = false
	
	# Handle left and right movement
	if _is_in_normal_state():
		velocity.x = horizontal_dir * speed
		
	if is_on_floor():
		_coyote_timer.start(COYOTE_TIME_WINDOW)

	# Handle jumping
	if _is_in_normal_state() and Input.is_action_just_pressed(_controls.up) and (not _coyote_timer.is_stopped()):
		_start_jump()
	
	# Handle going down platforms
	var collide_with_platforms: bool = not Input.is_action_pressed(_controls.down)
	set_collision_mask_value(2, collide_with_platforms)
	
	# Handle dashing
	if _is_in_normal_state() and Input.is_action_just_pressed(_controls.dash) and dashes > 0 and _ground_dash_cooldown_timer.is_stopped():
		_start_dash(delta)
	elif is_dashing and _dash_timer.is_stopped():
		_end_dash()
	if is_on_floor() and (not is_dashing) and _ground_dash_cooldown_timer.is_stopped():
		_refill_dash()
	elif not is_on_floor():
		_ground_dash_cooldown_timer.stop()

	# Move the character
	move_and_slide()


func _start_jump() -> void:
	velocity.y = -jump_force
	_coyote_timer.stop()
	_refill_dash()


func _gets_grabbed() -> void:
	_main_animation_player.play("is_grabbed")


func _start_dash(delta: float) -> void:
	is_dashing = true
	dashes -= 1
	clamp(dashes, 0, max_dashes - 1)
	_dash_timer.start(dash_time)
	
	var dash_dir: Vector2 = _get_dash_dir(_dir)
	velocity = dash_dir * dash_speed_factor * speed * delta


func _end_dash() -> void:
	is_dashing = false
	velocity.y *= 0.4
	if is_on_floor():
		_ground_dash_cooldown_timer.start(ground_dash_cooldown)


func _refill_dash() -> void:
	var prev_dashes = dashes
	dashes = max_dashes
	
	if prev_dashes < max_dashes and _ground_dash_cooldown_timer.is_stopped():
		_status_animation_player.play("dash_recharge")


func _handle_facing() -> void:
	if velocity.x > 0.0:
		facing = Facing.RIGHT
		rotation_degrees = 0
		scale.y = abs(scale.y)
	elif velocity.x < 0.0:
		facing = Facing.LEFT
		rotation_degrees = 180
		scale.y = -1.0 * abs(scale.y)


func _is_in_normal_state() -> bool:
	return (not is_dashing) and (not is_grabbing) and (not is_grabbed)


func _get_dash_dir(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		var default_dir_x: float
		if facing == Facing.RIGHT:
			default_dir_x = 1.0
		else:
			default_dir_x = -1.0
		return Vector2(default_dir_x, 0.0)
	else:
		return dir

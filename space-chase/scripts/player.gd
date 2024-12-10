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

const COYOTE_TIME_WINDOW: float = 0.06 # Time in seconds in which jumping is possible after no longer being on the floor
const HELD_POS_HEIGHT: float = 15.0 # How high held targets should be
const HOLD_TIME: float = 5.0 # How long a player is able to hold
const HOLD_TIMER_REDUCTION: float = 0.5 # How much to reduce the hold timer for each button mashed by held player
const RESPAWN_TIME: float = 2.0 # How long for player to respawn as a ghost
const GHOST_TIME: float = 4.0 # How long for player to stop being a ghost

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
@export var respawn_pos: Node2D = null

var energy: float = 0
var facing: Direction.Facing = Direction.Facing.RIGHT
var is_stunned = false # During knockback from being thrown, dash stuns, and grab techs
var dashes: int = max_dashes
var is_dashing: bool = false
var is_grabbing: bool = false # Currently in the grab animation
var is_holding: bool = false # Currently grabbing/holding the othe player
var is_held: bool = false # Currently grabbed/held by the other player
var is_fast_falling: bool = false
var is_holding_jump: bool = false
var is_dead: bool = false # Mutually exclusive to is_ghost
var is_ghost: bool = false

var _controls: PlayerControls # Initialized based on player_id
var _dir: Vector2 # Stores direction of 8-way input
var _hold_timer: Timer
var _dash_timer: Timer
var _ground_dash_cooldown_timer: Timer
var _coyote_timer: Timer
var _stun_timer: Timer # Wait while player is stunned from knockback
var _respawn_timer: Timer # Wait until player respawns as a ghost
var _ghost_timer: Timer # Wait until player stops being a ghost
var _held_target: Node2D = null

@onready var _main_animation_player: AnimationPlayer = $MainAnimationPlayer
@onready var _status_animation_player: AnimationPlayer = $StatusAnimationPlayer
@onready var jump_sound: AudioStreamPlayer2D = $Audio/Jump
@onready var run_sound: AudioStreamPlayer2D = $Audio/Run
@onready var dash_sound: AudioStreamPlayer2D = $Audio/Dash
@onready var dash_refill_sound: AudioStreamPlayer2D = $Audio/DashRefill
@onready var respawn_sound: AudioStreamPlayer2D = $Audio/Respawn

func _ready() -> void:
	GameStateManager.player_mashing_while_held.connect(_reduce_hold_timer)
	
	# Set contrls based on player_id
	if player_id == GameStateManager.PlayerID.PLAYER_1:
		_controls = PlayerControls.get_p1_controls()
	elif player_id == GameStateManager.PlayerID.PLAYER_2:
		_controls = PlayerControls.get_p2_controls()
	else:
		print("ERROR: INVALID PLAYER_ID, CANNOT SET CONTROLS")
	
	# Check for respawn pos
	if respawn_pos == null:
		print("ERROR: respawn_pos must be set!")
	
	# Set player color
	if has_node("Sprite2D"):
		$Sprite2D.material.set("shader_parameter/inputColor", player_color)
	
	# Initialize timers
	_hold_timer = Timer.new()
	_hold_timer.one_shot = true
	add_child(_hold_timer)
	_dash_timer = Timer.new()
	_dash_timer.one_shot = true
	add_child(_dash_timer)
	_ground_dash_cooldown_timer = Timer.new()
	_ground_dash_cooldown_timer.one_shot = true
	add_child(_ground_dash_cooldown_timer)
	_coyote_timer = Timer.new()
	_coyote_timer.one_shot = true
	add_child(_coyote_timer)
	_stun_timer = Timer.new()
	_stun_timer.one_shot = true
	_stun_timer.timeout.connect(_stop_knockback)
	add_child(_stun_timer)
	_respawn_timer = Timer.new()
	_respawn_timer.one_shot = true
	_respawn_timer.timeout.connect(_start_ghost)
	add_child(_respawn_timer)
	_ghost_timer = Timer.new()
	_ghost_timer.one_shot = true
	_ghost_timer.timeout.connect(_stop_ghost)
	add_child(_ghost_timer)


func _physics_process(delta: float) -> void:
	# Return early if dead (ghost players aren't considered dead)
	if is_dead:
		return
	
	# Get input direction
	var horizontal_dir := Input.get_axis(_controls.left, _controls.right)
	var vertical_dir := Input.get_axis(_controls.up, _controls.down)
	_dir = Vector2(horizontal_dir, vertical_dir).normalized()
	
	_handle_ordering() # Z-index
	_handle_facing() # Looking left/right
	
	# Ghost movement (return early to prevent normal movement)
	if is_ghost:
		_move_as_ghost(delta)
		return
	
	# Handle gravity
	if (not is_dashing) and (not is_held) and (not is_on_floor()):
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
	if _can_move():
		velocity.x = horizontal_dir * speed
		if is_on_floor() and velocity.x != 0:
			if not run_sound.playing:
				run_sound.play()
		else:
			run_sound.stop()

	# Handle jumping
	if _can_move() and Input.is_action_just_pressed(_controls.up) and (not _coyote_timer.is_stopped()):
		_start_jump()
	if is_on_floor():
		_coyote_timer.start(COYOTE_TIME_WINDOW)
	
	# Handle going down platforms
	var collide_with_platforms: bool = not Input.is_action_pressed(_controls.down)
	set_collision_mask_value(2, collide_with_platforms)
	
	# Handle grabbing
	if _is_in_normal_state() and Input.is_action_just_pressed(_controls.grab):
		_try_grab()
	# Handle forced release
	if is_holding and _hold_timer.is_stopped():
		_release()
	# Handle throwing
	elif is_holding and (not Input.is_action_pressed(_controls.grab)):
		# Voluntary release
		if Input.is_action_pressed(_controls.down):
			_release()
		# Normal or high throw
		else:
			var high_throw: bool = Input.is_action_pressed(_controls.up)
			_throw(high_throw)
	
	# Allow held player to mash out
	if is_held and _controls.any_control_just_pressed():
		_status_animation_player.play("input_mash")
		GameStateManager.player_mashing_while_held.emit()
	
	# Move the held player relatively
	if is_holding and _held_target:
		_move_held_target()
	
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


# -------------------- Public functions --------------------

func instakill() -> void: # Called by hitbox
	if is_dead or is_ghost:
		return
	
	# Release the held player
	if is_holding:
		_release()
	
	reset_status() # Safety check incase of incorrect statuses
	
	is_dead = true
	_main_animation_player.play("death")
	
	_disable_interactions()
	
	_respawn_timer.start(RESPAWN_TIME)


func hold(target: Node2D) -> void: # Called by grabbox
	is_holding = true
	_held_target = target
	_hold_timer.start(HOLD_TIME)


func got_grabbed() -> void: # Called by grabbox
	is_held = true
	_main_animation_player.play("held")


func thrown(direction: Direction.Facing, high_throw: bool = false) -> void:
	is_held = false
	var x_force: float = 300.0
	var y_force_damping: float = 1.0
	var high_throw_factor: float = 1.5 if high_throw else 1.0
	var force := Vector2(Direction.get_sign_factor(direction) * x_force, high_throw_factor * y_force_damping * -x_force)
	_start_knockback(force, 0.4)


func released() -> void:
	is_held = false
	var x_force: float = 100
	var force := Vector2(Direction.get_sign_factor(facing) * x_force, x_force)
	_start_knockback(force, 0.2)


func grab_tech() -> void: # Called by grabbox
	# BUG: When grab teching the grabboxes are still enabled. Players are also being thrown instead of just grab teching
	
	# Backwards knockback
	is_holding = false
	is_held = false
	var x_force: float = 10.0
	var x_force_sign: float = Direction.get_sign_factor(Direction.get_opposite_faing(facing))
	var y_force_damping: float = 0.7
	var force := Vector2(x_force_sign * x_force, y_force_damping * -x_force)
	_start_knockback(force, 0.5)


func dash_stun(direction: Direction.Facing) -> void: # Called by hurtbox
	# Backwards knockback
	is_held = false
	_end_dash()
	var x_force: float = 100.0
	var x_force_sign: float = Direction.get_sign_factor(direction)
	var y_force_damping: float = 0.5
	var force := Vector2(x_force_sign * x_force, y_force_damping * -x_force)
	_start_knockback(force, 0.3)


func reset_status() -> void:
	is_stunned = false
	is_dashing = false
	is_grabbing = false
	is_holding = false
	is_held = false
	is_fast_falling = false
	is_holding_jump = false
	is_dead = false
	is_ghost = false

# -------------------- Private functions --------------------

func _start_ghost() -> void:
	is_dead = false
	is_ghost = true
	_main_animation_player.play("respawn_as_ghost")
	global_position = respawn_pos.global_position
	_ghost_timer.start(GHOST_TIME)
	
	# Respawn sound effect
	#respawn_sound.play()


func _stop_ghost() -> void: # Respawn as normal player
	
	
	is_ghost = false
	
	_main_animation_player.play("respawn_as_normal")
	
	_enable_interactions()
	
	# Kill the player if inside solid ground
	if test_move(global_transform, Vector2.ZERO):
		instakill()
		return


func _move_as_ghost(delta: float) -> void:
	# Ghost 8-way movement
	if not is_dashing:
		velocity = _dir * speed
	
	# Ghost dash
	if (not is_dashing) and Input.is_action_just_pressed(_controls.dash):
		_start_dash(delta)
	elif is_dashing and _dash_timer.is_stopped():
		_end_dash()
	
	move_and_slide()


# Used to apply knockback (during which the player is stunned)
func _start_knockback(force: Vector2, stun_time: float) -> void:
	is_stunned = true
	_main_animation_player.play("knockback")
	
	velocity = force
	
	_stun_timer.start(stun_time)


func _stop_knockback():
	is_stunned = false
	_main_animation_player.stop()


func _start_jump() -> void:
	velocity.y = -jump_force
	_coyote_timer.stop()
	_refill_dash()
	jump_sound.play()


func _try_grab() -> void:
	_main_animation_player.play("grab") # Temporarily enables grabbox
	# Grab logic handled by grabbox


func _throw(high_throw: bool = false) -> void: # Held target is thrown ahead
	is_holding = false
	_held_target.thrown(facing, high_throw)
	_held_target = null


func _release() -> void: # Held target is released from the grab
	is_holding = false
	_held_target.released()
	_held_target = null


func _move_held_target() -> void:
	_held_target.global_position = global_position + Vector2(0, -HELD_POS_HEIGHT)
	if velocity.x > 0.0:
		_held_target.facing = Direction.Facing.RIGHT
	elif velocity.x < 0.0:
		_held_target.facing = Direction.Facing.LEFT
	Direction.flip_horizontal(_held_target, facing)


func _reduce_hold_timer() -> void:
	if _hold_timer.is_stopped() or is_zero_approx(_hold_timer.time_left):
		return
	var new_hold_time = _hold_timer.time_left - HOLD_TIMER_REDUCTION
	if new_hold_time <= 0:
		_hold_timer.stop()
	else:
		_hold_timer.start(new_hold_time)


func _start_dash(delta: float) -> void:
	dash_sound.play()
	
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
		# Dash refill sound
		


func _refill_dash() -> void:
	var prev_dashes = dashes
	dashes = max_dashes
	
	if prev_dashes < max_dashes and _ground_dash_cooldown_timer.is_stopped():
		_status_animation_player.play("dash_recharge")
		dash_refill_sound.play()


func _handle_ordering() -> void:
	if is_ghost:
		z_index = 1
	elif is_held:
		z_index = -1
	else:
		z_index = 0


func _handle_facing() -> void:
	if velocity.x > 0.0:
		facing = Direction.Facing.RIGHT
	elif velocity.x < 0.0:
		facing = Direction.Facing.LEFT
	Direction.flip_horizontal(self, facing)


func _is_in_normal_state() -> bool:
	return (not is_dashing) and (not is_holding) and (not is_held) and (not is_stunned) and (not is_ghost)


func _can_move() -> bool:
	return (not is_dashing) and (not is_held) and (not is_stunned)


func _get_dash_dir(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		var default_dir_x: float
		if facing == Direction.Facing.RIGHT:
			default_dir_x = 1.0
		else:
			default_dir_x = -1.0
		return Vector2(default_dir_x, 0.0)
	else:
		return dir


func _enable_interactions() -> void:
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	# Enable all Area2D
	for child in get_children():
		if child is Area2D:
			child.monitoring = true


func _disable_interactions() -> void:
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	# Keep mask for bit 6 (world border)
	# Disable all Area2D
	for child in get_children():
		if child is Area2D:
			child.monitoring = false

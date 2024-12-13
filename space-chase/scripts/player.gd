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

const PlayerID = GameStateManager.PlayerID

const DEFAULT_SPEED: float = 200.0
const DEFAULT_JUMP_FORCE: float = 350.0
const DEFAULT_THROW_STRENGTH: float = 1.0
const DEFAULT_DASH_SPEED: float = 430.0

const COYOTE_TIME_WINDOW: float = 0.12 # Time in seconds in which jumping is possible after no longer being on the floor
const HELD_POS_HEIGHT: float = 15.0 # How high held targets should be
const HOLD_TIME: float = 5.0 # How long a player is able to hold
const HOLD_TIMER_REDUCTION: float = 0.5 # How much to reduce the hold timer for each button mashed by held player
const RESPAWN_TIME: float = 1.5 # How long for player to respawn as a ghost
const GHOST_TIME: float = 2.0 # How long for player to stop being a ghost

@export_category("Main Settings")
@export var player_id := GameStateManager.PlayerID.PLAYER_1
@export var player_color: Color = Color.BLACK
@export var dash_color_gradient: Gradient = load("res://resources/red_gradient.tres")
@export_category("Physics Settings")
@export var speed: float = DEFAULT_SPEED
@export var throw_strength: float = DEFAULT_THROW_STRENGTH
@export var jump_force: float = DEFAULT_JUMP_FORCE
@export var max_dashes: int = 1
@export var dash_speed: float = DEFAULT_DASH_SPEED
@export var dash_time: float = 0.15
@export var ground_dash_cooldown: float = 0.7
@export_range (0, 1800) var gravity: float = 1600.0
@export var terminal_velocity: float = 400.0
@export_range (1.0, 5.0) var fast_fall_factor: float = 2.0
@export_range (0.0, 1.0) var hold_jump_gravity_reduction: float = 0.5
@export var respawn_pos: Node2D = null

var facing: Direction.Facing = Direction.Facing.RIGHT
var dashes: int = max_dashes
var active_shield: bool = false

var is_idle: bool = true
var is_running: bool = false
var is_stunned: bool = false # During knockback from being thrown, dash stuns, and grab techs
var is_dashing: bool = false
var is_grabbing: bool = false # Currently in the grab animation
var is_holding: bool = false # Currently grabbing/holding the othe player
var is_held: bool = false # Currently grabbed/held by the other player
var is_fast_falling: bool = false
var is_holding_jump: bool = false
var is_jumping: bool = false
var is_dead: bool = false # Mutually exclusive to is_ghost
var is_ghost: bool = false
var is_respawning: bool # if spawning whether that be (dead to ghost) or (ghost to normal)

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

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var main_animation_player: AnimationPlayer = $MainAnimationPlayer
@onready var status_animation_player: AnimationPlayer = $StatusAnimationPlayer

@onready var jump_sound: AudioStreamPlayer2D = $Audio/Jump
@onready var run_sound: AudioStreamPlayer2D = $Audio/Run
@onready var dash_sound: AudioStreamPlayer2D = $Audio/Dash
@onready var dash_refill_sound: AudioStreamPlayer2D = $Audio/DashRefill
@onready var respawn_sound: AudioStreamPlayer2D = $Audio/Respawn
@onready var death_sound: AudioStreamPlayer2D = $Audio/Death
@onready var grabbed_sound: AudioStreamPlayer2D = $Audio/Grabbed
@onready var thrown_sound: AudioStreamPlayer2D = $Audio/Thrown

func _ready() -> void:
	# Signals
	GameStateManager.player_mashing_while_held.connect(_reduce_hold_timer)
	GameStateManager.powerup_collected.connect(_on_powerup_collected)
	
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
		GameStateManager.player_colors[player_id] = player_color
	
	# Set dash trail color
	if has_node("DashTrail"):
		$DashTrail.gradient = dash_color_gradient
	
	# Start animation tree
	animation_tree.active = true
	
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
	
	GameStateManager.player_ready.emit(player_id)


func _physics_process(delta: float) -> void:
	# Return early if dead (ghost players aren't considered dead
	if is_dead:
		return
	
	# Get input direction
	var horizontal_dir := Input.get_axis(_controls.left, _controls.right)
	var vertical_dir := Input.get_axis(_controls.up, _controls.down)
	_dir = Vector2(horizontal_dir, vertical_dir).normalized()
	
	# Update basis movement statuses
	is_jumping = not is_on_floor()
	is_idle = is_zero_approx(velocity.x)
	is_running = not is_zero_approx(velocity.x)
	
	# Update visuals
	_handle_ordering() # Z-index
	_handle_facing() # Looking left/right
	$ShieldParticles.visible = active_shield
	
	# Check for jump input
	var use_up_as_jump: bool = PlayerControls.use_up_as_jump[player_id]
	var has_jumped: bool = Input.is_action_just_pressed(_controls.jump) or (use_up_as_jump and Input.is_action_just_pressed(_controls.up))
	var holding_jump: bool = Input.is_action_pressed(_controls.jump) or (use_up_as_jump and Input.is_action_pressed(_controls.up))
	
	# Ghost movement (return early to prevent normal movement)
	if is_ghost:
		_move_as_ghost(delta)
		return
	
	# Handle gravity
	if (not is_dashing) and (not is_held) and (not is_on_floor()):
		var apply_gravity: float = gravity * delta
		var acting_terminal_velocity: float = terminal_velocity
		is_fast_falling = Input.is_action_pressed(_controls.down)
		is_holding_jump = holding_jump and velocity.y < 0
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
	if _can_move() and has_jumped and (not _coyote_timer.is_stopped()):
		_start_jump()
	if is_on_floor():
		_coyote_timer.start(COYOTE_TIME_WINDOW)
	
	# Handle going down platforms
	var collide_with_platforms: bool = not Input.is_action_pressed(_controls.down)
	set_collision_mask_value(2, collide_with_platforms)
	
	# Handle grabbing
	if _is_in_normal_state() and Input.is_action_just_pressed(_controls.grab):
		_start_grab()
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
			var high_throw: bool = vertical_dir < 0.0
			_throw(high_throw)
	
	# Allow held player to mash out
	if is_held and _controls.any_control_just_pressed():
		status_animation_player.play("input_mash")
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


func _process(_delta: float) -> void:
	_update_animation_tree()
	

# -------------------- Public functions --------------------

func instakill() -> void: # Called by hitbox
	if is_dead or is_ghost:
		return
	
	var opposite_player_id = 1 if player_id == 0 else 0
	var energy_lost: float = GameStateManager.remove_player_energy(25, player_id)
	GameStateManager.add_player_energy(energy_lost, opposite_player_id)
	
	# Release the held player
	if is_holding:
		_release()
	
	PowerupManager._clear_all_buffs(self)
	_reset_status() # Safety check incase of incorrect statuses
	
	is_dead = true
	#main_animation_player.play("death")
	
	_disable_interactions()
	
	_respawn_timer.start(RESPAWN_TIME)
	
	# play death sound
	death_sound.play()


func hold(target: Node2D) -> void: # Called by grabbox
	is_grabbing = false
	is_holding = true
	is_held = false
	_held_target = target
	_hold_timer.start(HOLD_TIME)
	target.got_grabbed()


func got_grabbed() -> void: # Called by hold function
	is_held = true
	is_holding = false
	
	grabbed_sound.play()


# Called by the thrower player on the thrown player
func thrown(throw_direction: Vector2, thrower_throw_strength: float) -> void:
	is_held = false
	var force_amount: float = 270.0
	
	var force := throw_direction.sign() * Vector2(force_amount, force_amount * 1.5)
	if force.x == 0.0:
		force.y *= 1.2
	if force.y == 0.0:
		force.y = -force_amount * 1.1
	
	_start_knockback(force * thrower_throw_strength , 0.45)
	
	thrown_sound.play()


func released() -> void:
	is_held = false
	var x_force: float = 100
	var force := Vector2(Direction.get_sign_factor(facing) * x_force, x_force)
	_start_knockback(force, 0.2)


func grab_tech() -> void: # Called by grabbox
	# BUG: When grab teching the grabboxes are still enabled. Players are also being thrown instead of just grab teching
	
	# Backwards knockback
	is_grabbing = false
	is_holding = false
	is_held = false
	var x_force: float = 100.0
	var x_force_sign: float = Direction.get_sign_factor(Direction.get_opposite_faing(facing))
	var force := Vector2(x_force_sign * x_force, 1.2 * -x_force)
	_start_knockback(force, 0.5)


func dash_stun(direction: Direction.Facing) -> void: # Called by hurtbox
	_end_dash()
	var x_force: float = 125.0
	var x_force_sign: float = Direction.get_sign_factor(direction)
	var force := Vector2(x_force_sign * x_force, 1.2 * -x_force)
	_start_knockback(force, 0.3)


func can_charge() -> bool:
	return (not is_held) and (not is_ghost)


# -------------------- Private functions --------------------

func _on_powerup_collected(collector_player_id: GameStateManager.PlayerID) -> void:
	if collector_player_id == player_id:
		status_animation_player.play("collect_powerup")


func _start_ghost() -> void:
	is_dead = false
	is_ghost = true
	is_respawning = true
	#main_animation_player.play("respawn_as_ghost")
	
	global_position = respawn_pos.global_position
	_ghost_timer.start(GHOST_TIME)
	
	# Respawn sound effect
	respawn_sound.play()
	#respawn_sound.seek(2.0)


func _stop_ghost() -> void: # Respawn as normal player
	is_ghost = false
	is_respawning = true
	#main_animation_player.play("respawn_as_normal")
	
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
	
	velocity = force
	
	_stun_timer.start(stun_time)


func _stop_knockback():
	is_stunned = false
	#main_animation_player.stop() # Stop knockback animation


func _start_jump() -> void:
	velocity.y = -jump_force
	_coyote_timer.stop()
	_refill_dash()
	jump_sound.play()


func _start_grab() -> void:
	is_grabbing = true
	#main_animation_player.play("grab") # Temporarily enables grabbox
	# Grab logic handled by grabbox
	# At the end of the grab, the grab animation calls _stop_grab()


func _stop_grab() -> void: # Called at the end of teh grab animation
	is_grabbing = false


func _throw(_high_throw: bool = false) -> void: # Held target is thrown ahead
	is_holding = false
	_held_target.thrown(_get_action_dir(_dir), throw_strength)
	_held_target = null
	#main_animation_player.stop() # Stop held animation


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


func _start_dash(_delta: float) -> void:
	dash_sound.play()
	
	is_dashing = true
	dashes -= 1
	clamp(dashes, 0, max_dashes - 1)
	_dash_timer.start(dash_time)
	
	var dash_dir: Vector2 = _get_action_dir(_dir)
	velocity = dash_dir * dash_speed


func _end_dash() -> void:
	is_dashing = false
	velocity.y *= 0.4
	if is_on_floor() and dashes <= 0.0:
		_ground_dash_cooldown_timer.start(ground_dash_cooldown)
		# Dash refill sound goes here


func _refill_dash() -> void:
	var prev_dashes = dashes
	dashes = max_dashes
	
	if prev_dashes < max_dashes and _ground_dash_cooldown_timer.is_stopped():
		status_animation_player.play("dash_recharge")
		dash_refill_sound.play()


func _handle_ordering() -> void:
	if is_ghost:
		z_index = 2
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


func _get_action_dir(dir: Vector2) -> Vector2: # For dashes and throws
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
			child.set_deferred("monitoring", true)


func _disable_interactions() -> void:
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	# Keep mask for bit 6 (world border)
	# Disable all Area2D
	for child in get_children():
		if child is Area2D:
			child.set_deferred("monitoring", false)


func _started_respawning() -> void: # Called at the start of respawn animations
	is_respawning = true


func _stopped_respawning() -> void: # Called at the end of respawn animations
	is_respawning = false


func _reset_status() -> void:
	is_stunned = false
	is_dashing = false
	is_grabbing = false
	is_holding = false
	is_held = false
	is_fast_falling = false
	is_holding_jump = false
	is_dead = false
	is_ghost = false


func _update_animation_tree() -> void:		
	animation_tree["parameters/conditions/is_idle"] = is_idle
	animation_tree["parameters/conditions/is_running"] = is_running
	animation_tree["parameters/conditions/is_jumping"] = is_jumping
	animation_tree["parameters/conditions/not_jumping"] = not is_jumping
	animation_tree["parameters/conditions/is_fast_falling"] = is_fast_falling
	animation_tree["parameters/conditions/not_fast_falling"] = not is_fast_falling
	animation_tree["parameters/conditions/is_dashing"] = is_dashing
	animation_tree["parameters/conditions/not_dashing"] = not is_dashing
	
	animation_tree["parameters/conditions/is_grabbing"] = is_grabbing
	
	animation_tree["parameters/conditions/is_holding"] = is_holding
	animation_tree["parameters/conditions/not_holding"] = not is_holding
	animation_tree["parameters/conditions/is_held"] = is_held
	animation_tree["parameters/conditions/not_held"] = not is_held
	
	animation_tree["parameters/conditions/is_stunned"] = is_stunned
	animation_tree["parameters/conditions/not_stunned"] = not is_stunned
	
	animation_tree["parameters/conditions/is_ghost"] = is_ghost
	animation_tree["parameters/conditions/not_ghost"] = not is_ghost
	animation_tree["parameters/conditions/is_dead"] = is_dead

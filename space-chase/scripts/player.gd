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

@export var player_id := GameStateManager.PlayerID.PLAYER_1
@export var speed: float = 200.0
@export var jump_force: float = 350.0
@export_range (0, 1800) var gravity: float = 1600.0
@export_range (1.0, 5.0) var fast_fall_factor: float = 2.0
@export_range (0.0, 1.0) var hold_jump_gravity_reduction: float = 0.5

var _controls: PlayerControls = null # Initialized bassed on player_id


func _ready() -> void:
	if player_id == GameStateManager.PlayerID.PLAYER_1:
		_controls = PlayerControls.get_p1_controls()
	elif player_id == GameStateManager.PlayerID.PLAYER_2:
		_controls = PlayerControls.get_p2_controls()
	else:
		print("ERROR: INVALID PLAYER_ID, CANNOT SET CONTROLS")


func _physics_process(delta: float) -> void:
	# Handle gravity
	var apply_gravity: float = gravity * delta
	if Input.is_action_pressed(_controls.down): # Fast fall
		apply_gravity *= fast_fall_factor
	elif Input.is_action_pressed(_controls.up): # Hold jump
		apply_gravity *= hold_jump_gravity_reduction
	velocity.y += apply_gravity
	
	# Handle left and right movement
	var horizontal_dir := Input.get_axis(_controls.left, _controls.right)
	velocity.x = horizontal_dir * speed

	# Handle jumping
	if Input.is_action_pressed(_controls.up) and is_on_floor():
		velocity.y = -jump_force
	
	# Handle going down platforms
	var collide_with_platforms: bool = not Input.is_action_pressed(_controls.down)
	set_collision_mask_value(2, collide_with_platforms)
	
	# Move the character
	move_and_slide()

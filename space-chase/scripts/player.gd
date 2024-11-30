class_name Player
extends CharacterBody2D

"""
Identified by player id (enum is from game state manager)
Exported variable for respective charging station
Movement mechanics
- left/right
- go down platforms
- jump
- 8 direction dash
Grab mechanics
- Can grab/throw the other player
- Can be grabbed/thrown by the other player (bool for grabbed)
If dies, give the other player energy (through game state manager)
If close to respective charging station, slowly charge up the station (through game state manager)
"""

# Placeholder player movement for development

# Movement variables
@export var speed: float = 200.0
@export var jump_force: float = 400.0
@export var gravity: float = 900.0

func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta
	
	# Handle left and right movement
	if Input.is_action_pressed("left"):
		velocity.x = -speed
	elif Input.is_action_pressed("right"):
		velocity.x = speed
	else:
		velocity.x = 0

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	
	# Move the character
	move_and_slide()

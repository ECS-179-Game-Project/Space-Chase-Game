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

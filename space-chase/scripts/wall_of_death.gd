class_name WallOfDeath
extends Node2D

const REACH_SPEED: float = 5
const RETURN_SPEED: float = 5

@export_range(0, 1) var reach_chance: float = 0.001
@export_range(0, 300) var min_reach: float = 25
@export_range(0, 300) var max_reach: float = 50
@export_range(0, 300) var vertical_reach: float = 50

@onready var enemy_nodes: Array = $Wall.get_children()

var _enemies: Array[Enemy]

func _ready() -> void:
	randomize()
	for enemy_node in enemy_nodes:
		var enemy := Enemy.new()
		enemy.node = enemy_node
		enemy.is_reaching = false
		enemy.is_returning = false
		enemy.origin_pos = enemy_node.position
		enemy.reach_pos = Vector2.ZERO
		_enemies.append(enemy)


func _physics_process(delta: float) -> void:
	var i: int = 0
	for enemy in _enemies:
		if enemy.is_reaching:
			enemy.node.position = enemy.node.position.lerp(enemy.reach_pos, REACH_SPEED * delta)
			if is_equal_approx(enemy.node.position.x, enemy.reach_pos.x):
				_start_enemy_return(i)
		
		elif enemy.is_returning:
			enemy.node.position = enemy.node.position.lerp(enemy.origin_pos, RETURN_SPEED * delta)
			if is_equal_approx(enemy.node.position.x, enemy.origin_pos.x):
				enemy.is_returning = false
		
		elif randf() < reach_chance:
			_start_enemy_reach(i)
		
		i += 1


func _start_enemy_reach(i: int) -> void:
	_enemies[i].is_reaching = true
	_enemies[i].is_returning = false
	
	var reach_x = _enemies[i].origin_pos.x + randf_range(min_reach, max_reach)
	var reach_y = _enemies[i].origin_pos.y + randf_range(-vertical_reach, vertical_reach)
	_enemies[i].reach_pos = Vector2(reach_x, reach_y)


func _start_enemy_return(i: int) -> void:
	_enemies[i].is_reaching = false
	_enemies[i].is_returning = true


class Enemy:
	var node: Node2D
	var is_reaching: bool
	var is_returning: bool
	var origin_pos: Vector2
	var reach_pos: Vector2

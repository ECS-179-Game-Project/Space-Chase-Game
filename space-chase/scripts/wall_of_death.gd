class_name WallOfDeath
extends Node2D

@export_range(0, 1) var reach_chance: float = 0.001
@export_category("Reach Speed")
@export_range(0, 20) var min_speed: float = 1
@export_range(0, 20) var max_speed: float = 5
@export_category("Reach Distance")
@export_range(0, 300) var min_reach: float = 25
@export_range(0, 300) var max_reach: float = 75
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
		enemy.speed = 0.0
		_enemies.append(enemy)


func _physics_process(delta: float) -> void:
	var i: int = 0
	for enemy in _enemies:
		if enemy.is_reaching:
			enemy.node.position = enemy.node.position.lerp(enemy.reach_pos, enemy.speed * delta)
			if is_equal_approx(enemy.node.position.x, enemy.reach_pos.x):
				_start_enemy_return(i)
		
		elif enemy.is_returning:
			enemy.node.position = enemy.node.position.lerp(enemy.origin_pos, enemy.speed * delta)
			if is_equal_approx(enemy.node.position.x, enemy.origin_pos.x):
				enemy.is_returning = false
		
		elif randf() < reach_chance:
			_start_enemy_reach(i)
		
		i += 1


func _start_enemy_reach(i: int) -> void:
	var enemy: Enemy = _enemies[i]
	
	enemy.is_reaching = true
	enemy.is_returning = false
	
	var reach_x = enemy.origin_pos.x + randf_range(min_reach, max_reach)
	var reach_y = enemy.origin_pos.y + randf_range(-vertical_reach, vertical_reach)
	enemy.reach_pos = Vector2(reach_x, reach_y)
	
	var random_speed: float = randf_range(min_speed, max_speed)
	enemy.speed = random_speed


func _start_enemy_return(i: int) -> void:
	var enemy: Enemy = _enemies[i]
	
	enemy.is_reaching = false
	enemy.is_returning = true


class Enemy:
	var node: Node2D
	var is_reaching: bool
	var is_returning: bool
	var origin_pos: Vector2
	var reach_pos: Vector2
	var speed: float

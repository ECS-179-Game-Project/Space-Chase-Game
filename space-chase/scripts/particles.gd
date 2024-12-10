extends Node

signal request_particle_to_world(particle_index: int, position: Vector2, velocity: Vector2)

const MAX_EMITTERS = 32

var _active_particle_container: WorldParticleContainer = null
var _loaded_particles: Array[PackedScene] = []
var _loaded_id: Array[int] = []


func _ready():
	request_particle_to_world.connect(_on_request_particle_to_world)


func load_particle(particle_path: String) -> int:
	if not particle_path.is_absolute_path():
		push_error(particle_path, "is not a valid path.")
		return -1
	else:
		var particle_scene = load(particle_path) as PackedScene
		var new_particle = particle_scene.instantiate()
		if new_particle is TrackedParticles:
			var look = _loaded_id.find(new_particle.id)
			if look > -1:
				return look
			else:
				_loaded_particles.push_back(particle_scene)
				_loaded_id.push_back(new_particle.id)
				return _loaded_particles.size() - 1
		else:
			push_error("PackedScene at ", particle_path, " does not contain a valid particle.")
			return -1


func get_particle(index: int) -> GPUParticles2D:
	if _loaded_particles.size() > index:
		return _loaded_particles[index].instantiate()
	else:
		return null


func spawn_particle(index: int, parent: Node):
	parent.add_child(_loaded_particles[index].instantiate())


func set_active_container(node: WorldParticleContainer):
	_active_particle_container = node


func _on_request_particle_to_world(particle_index: int, position: Vector2):
	var particle = _loaded_particles[particle_index].instantiate()
	particle.global_position = position
	_active_particle_container.add_child(particle)

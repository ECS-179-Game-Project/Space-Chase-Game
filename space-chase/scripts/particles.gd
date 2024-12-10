extends Node

var _loaded_particles: Array[GPUParticles2D] = []

signal request_particle(particle_index: int, position: Vector2)

const MAX_EMITTERS = 32


func load_particle(particle_path: String) -> int:
	if not particle_path.is_valid_filename():
		push_error("Invalid path.")
		return -1
		
	var new_particle = load(particle_path).instantiate()
	if new_particle is GPUParticles2D:
		_loaded_particles.push_back(new_particle)
		return _loaded_particles.size()
	else:
		push_error("PackedScene at ", particle_path, " does not contain a valid particle.")
		return -1


func get_particle(index: int) -> GPUParticles2D:
	if _loaded_particles.size() > index:
		return _loaded_particles[index]
	else:
		return null

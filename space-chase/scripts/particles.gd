extends Node

## If particles are to be spawned in world, spawn as a child of this node.
var _active_particle_container: WorldParticleContainer = null 

var _loaded_particles: Array[PackedScene] = [] ## Stores loaded particle scenes.
var _loaded_id: Array[int] = [] ## Stores the id of each particle emitter to avoid duplicating.


## Sets the active particle container. Called by the container.
func set_active_container(node: WorldParticleContainer):
	_active_particle_container = node


## Loads the particle path into an array and returned an index for access.
## Store the index to use to access the particles.
func load_particle(particle_path: String) -> int:
	if not particle_path.is_absolute_path():
		push_error("Invalid path.")
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


## Returns an instance of a particle given an index.
func get_particle(index: int) -> GPUParticles2D:
	if _loaded_particles.size() > index:
		return _loaded_particles[index].instantiate()
	else:
		return null


## Creates a particle emitter under a parent node given an index.
func spawn_particle(index: int, parent: Node):
	if _loaded_particles.size() > index:
		parent.add_child(_loaded_particles[index].instantiate())
	else:
		push_error("Particle spawn failed. Index out of bounds.")


## Creates a particle emitter under the world container given an index.
func spawn_particle_to_world(particle_index: int, position: Vector2):
	if _loaded_particles.size() > particle_index:
		var particle = _loaded_particles[particle_index].instantiate()
		particle.global_position = position
		_active_particle_container.add_child(particle)
	else:
		push_error("Particle spawn failed. Index out of bounds.")
		

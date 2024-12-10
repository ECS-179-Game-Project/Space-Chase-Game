class_name OneShotParticles
extends GPUParticles2D


func _ready():
	one_shot = true
	emitting = true
	finished.connect(_on_finished)
	

func _on_finished():
	queue_free()

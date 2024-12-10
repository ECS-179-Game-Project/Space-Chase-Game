class_name OneShotParticles
extends TrackedParticles


func _ready():
	one_shot = true
	restart()
	finished.connect(_on_finished)
	

func _on_finished():
	queue_free()

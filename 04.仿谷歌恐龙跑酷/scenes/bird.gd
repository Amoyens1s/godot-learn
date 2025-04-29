extends Area2D

func _physics_process(delta: float) -> void:
	position.x -= get_parent().speed / 2

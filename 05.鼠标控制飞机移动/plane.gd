extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	if global_position.distance_to(get_global_mouse_position()) < 10: return
	
	var direction = (get_global_mouse_position() - global_position).normalized()
	
	rotation = direction.angle()
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

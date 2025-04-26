extends Area2D

@export var animator: AnimatedSprite2D
@export var slime_speed: float = -50

var is_death: bool = false

func _physics_process(delta: float) -> void:
	if not is_death:
		position += Vector2(slime_speed, 0) * delta
		
	if position.x < -260:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_death:
		body.game_over()


func _on_killed(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		animator.play("death")
		is_death = true
		area.queue_free()
		$CollisionShape2D.queue_free()
		get_tree().current_scene.score += 1
		$DeathSound.play()
		

func _on_death_animation_finished() -> void:
	queue_free()

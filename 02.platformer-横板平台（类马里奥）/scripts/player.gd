extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME = 0.15  # 200ms

var coyote_time_timer = 0.0
var can_jump = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		coyote_time_timer += delta
	else:
		coyote_time_timer = 0.0
		can_jump = true

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or (can_jump and coyote_time_timer <= COYOTE_TIME):
			velocity.y = JUMP_VELOCITY
			can_jump = false  # Reset the can_jump flag after jumping

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animation
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

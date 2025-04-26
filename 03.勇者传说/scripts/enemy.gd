extends CharacterBody2D
class_name Enemy

enum Direction {
	LEFT = -1,
	RIGHT = +1,
}

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

@export var direction := Direction.LEFT:
	set(v):
		direction = v

		if not is_node_ready():
			await ready

		graphics.scale.x = -direction

@export var max_speed: float = 180
@export var accleleration: float = 2000

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float


func move(speed: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, speed * direction, accleleration * delta)
	velocity.y += default_gravity * delta

	move_and_slide()

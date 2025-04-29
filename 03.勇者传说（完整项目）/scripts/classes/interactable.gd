extends Area2D
class_name Interactable

signal interacted


func _init() -> void:
	# 可交互节点不应该待在任何层上但应该主动寻找Player层上的对象
	# collision layer和mask并不是int，而是位域，不能直接赋值为2（Player层）
	collision_layer = 0
	collision_mask = 0

	# 打开和Player层的mask
	set_collision_mask_value(2, true)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interact() -> void:
	interacted.emit()


func _on_body_entered(player: Player) -> void:
	player.register_interactable(self)


func _on_body_exited(player: Player) -> void:
	player.unregister_interactable(self)

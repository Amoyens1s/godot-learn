extends Area2D
class_name Hitbox

# 需要告知外界打到了谁
signal hit(Hurtbox)


func _init() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(hurtbox: Hurtbox) -> void:
	# 是谁杀了我而我又杀了谁
	print("[Hit] %s => %s" % [owner.name, hurtbox.owner.name])
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)

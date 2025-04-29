extends CharacterBody2D

const SPEED = 300.0 # 定义角色移动速度为300像素/秒

func _physics_process(delta: float) -> void:
	# _physics_process是Godot的内置函数，在每个物理帧都会被调用
	# delta是上一帧到当前帧的时间间隔，用于平滑移动
	
	# 如果角色当前位置与鼠标位置的距离小于10像素，则停止移动
	# 避免角色在鼠标附近抖动
	if global_position.distance_to(get_global_mouse_position()) < 10: return
	
	# 计算从角色当前位置到鼠标位置的方向向量
	# get_global_mouse_position()获取鼠标在全局坐标系中的位置
	# global_position是角色在全局坐标系中的位置
	# normalized()将向量转换为单位向量，长度为1
	var direction = (get_global_mouse_position() - global_position).normalized()
	
	# 根据方向向量计算角色的旋转角度
	# angle()返回向量与正X轴之间的夹角，单位为弧度
	rotation = direction.angle()
	
	# 如果存在方向向量（即鼠标位置与角色位置不同）
	if direction:
		# 设置角色的速度向量
		# 将单位方向向量乘以速度，得到实际的速度向量
		velocity = direction * SPEED
	else:
		# 如果没有方向向量（即鼠标位置与角色位置相同），则停止移动
		velocity = Vector2.ZERO
		
	# 移动角色并处理碰撞
	# move_and_slide()是CharacterBody2D的内置函数，用于移动角色并检测碰撞
	move_and_slide()

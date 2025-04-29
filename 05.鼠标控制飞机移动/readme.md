这段代码之所以能让飞机跟着鼠标移动，是因为它实现了以下几个关键步骤：

1. **获取鼠标位置：** `get_global_mouse_position()` 函数用于获取鼠标在游戏世界中的全局坐标。这个坐标代表了鼠标在游戏场景中的精确位置。

2. **计算方向向量：**  `direction = (get_global_mouse_position() - global_position).normalized()` 这行代码计算了从飞机当前位置到鼠标位置的方向。具体来说，它首先计算了鼠标位置和飞机位置之间的差值向量（`get_global_mouse_position() - global_position`）。然后，`normalized()` 函数将这个向量转换为单位向量，单位向量只表示方向，长度为1。这确保了无论鼠标距离飞机多远，飞机的移动速度都是恒定的。

3. **旋转飞机：** `rotation = direction.angle()` 这行代码根据方向向量调整飞机的旋转角度。 `direction.angle()` 函数计算了方向向量与水平正方向（X轴）之间的夹角，并将这个角度赋值给飞机的 `rotation` 属性。这样，飞机就会旋转到面向鼠标的方向。

4. **移动飞机：**
   - `if direction:` 检查是否存在方向向量。如果鼠标位置与飞机位置不同，则 `direction` 向量存在，条件成立。
   - `velocity = direction * SPEED`  这行代码设置了飞机的速度向量。速度向量由单位方向向量（`direction`）乘以速度标量（`SPEED`）得到。`SPEED` 常量定义了飞机的移动速度。
   - `else: velocity = Vector2.ZERO` 如果鼠标位置与飞机位置相同，则将速度设置为零，飞机停止移动。

5. **应用速度并处理碰撞：** `move_and_slide()` 函数是 `CharacterBody2D` 类的一个内置函数，它负责根据速度向量移动飞机，并自动处理碰撞。如果飞机在移动过程中遇到障碍物，`move_and_slide()` 函数会调整飞机的移动轨迹，防止其穿透障碍物。

总而言之，这段代码通过不断获取鼠标位置，计算方向向量，调整飞机的旋转角度和速度，从而实现了飞机跟随鼠标移动的效果。
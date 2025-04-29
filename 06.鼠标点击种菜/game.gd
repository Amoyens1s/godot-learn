# 继承自 Node2D，用于实现 2D 游戏场景
extends Node2D

# 使用 @onready 确保节点在准备就绪时再获取引用
@onready var ground = $Ground # 地面层级引用
@onready var crop_layer = $Crops # 农作物层级引用

# 存储每个格子的水分等级
var water_level: Dictionary
# 存储每个格子的农作物信息
var crop: Dictionary

# 导出农作物数据配置，使用自定义资源类型 BlockData
@export var block: Dictionary[String, BlockData]

# 当前选择的农作物类型
var currently_equipped: String = "potato"

# 物理帧更新函数，处理农作物生长和水分消耗
func _physics_process(delta):
	# 遍历所有有水分的格子，随时间减少水分
	for pos in water_level:
		water_level[pos] -= delta
		if water_level[pos] <= 0:
			water_level.erase(pos)
			drying_tile(pos) # 水分耗尽时恢复地面贴图

	# 遍历所有种植的农作物
	for pos in crop:
		# 只有有水的农作物才会生长
		if water_level.has(pos):
			crop[pos]["duration"] += delta # 增加生长时间

			var duration = crop[pos]["duration"]
			var crop_name = crop[pos]["name"]

			# 检查生长阶段
			print(duration, block[crop_name].duration)
			if duration >= block[crop_name].duration:
				# 农作物完全成熟
				set_tile(crop_name, pos, crop_layer, block[crop_name].atlas_coords.size() - 1)
				crop[pos]["duration"] = - INF # 设置为可收获状态
			elif duration > 0:
				# 更新生长阶段的贴图
				var index = block[crop_name].growth_index(duration)
				set_tile(crop_name, pos, crop_layer, index)

# 输入处理函数
func _input(event):
	# 只处理鼠标按键事件
	if event is InputEventMouseButton and event.pressed:
		var tile_pos = get_snapped_position(get_global_mouse_position())

		# 左键用于浇水和收获
		if event.button_index == MOUSE_BUTTON_LEFT:
			var data = ground.get_cell_tile_data(tile_pos)
			var tile_name
			if data:
				tile_name = data.get_custom_data("tile_name")
				print(tile_name)
				watering_tile(tile_name, tile_pos, 3) # 浇水

			harvesting(tile_pos) # 尝试收获

		# 右键用于种植新的农作物
		if event.button_index == MOUSE_BUTTON_RIGHT and not crop.has(tile_pos):
			set_tile(currently_equipped, tile_pos, crop_layer)
			crop[tile_pos] = {
				"name": currently_equipped,
				"duration": 0
			}
			print(crop)

# 获取鼠标位置对应的网格坐标
func get_snapped_position(global_pos: Vector2) -> Vector2i:
	var local_pos = ground.to_local(global_pos)
	var tile_pos = ground.local_to_map(local_pos)
	return tile_pos

# 设置指定位置的贴图
func set_tile(tile_name: String, cell_pos: Vector2i, layer: TileMapLayer, coord: int = 0):
	if block.has(tile_name):
		layer.set_cell(cell_pos, block[tile_name].source_id, block[tile_name].atlas_coords[coord])

# 给指定位置浇水
func watering_tile(tile_name: String, pos: Vector2i, amount: float = 1.0):
	water_level[pos] = amount
	set_tile(tile_name, pos, ground, 1) # 更新为湿润的地面贴图
	print(water_level)

# 处理土地干燥
func drying_tile(pos):
	var tile_pos = get_snapped_position(pos)
	var data = ground.get_cell_tile_data(tile_pos)
	var tile_name
	if data:
		tile_name = data.get_custom_data("tile_name")
		set_tile(tile_name, pos, ground) # 恢复为干燥的地面贴图

# 收获成熟的农作物
func harvesting(pos):
	if crop_layer.get_cell_source_id(pos) != -1 and crop.has(pos) and crop[pos]["duration"] < 0:
		crop_layer.erase_cell(pos) # 清除农作物贴图
		print(crop[pos]["name"])
		crop.erase(pos) # 移除农作物数据

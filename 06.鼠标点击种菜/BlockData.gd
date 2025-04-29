extends Resource
class_name BlockData

# tileset自定义属性
@export var tile_name: String

# tilemap熟悉，图集坐标和源
@export var atlas_coords: Array[Vector2i] = []
@export var source_id: int = 0

# 作物成长速度
@export var duration: float

func growth_index(time: float):
	var stage_index: int = int((time / duration) * (atlas_coords.size() - 1))
	print("stage_index " + str(stage_index))
	return stage_index

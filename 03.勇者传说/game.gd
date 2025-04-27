extends Node

const SAVE_PATH := "user://save.json"

# 存储场景信息=> {
#     enemies_alive => [敌人的路径]
# }
var world_stats := {}

@onready var player_stats: Stats = $PlayerStats
@onready var color_rect: ColorRect = $ColorRect
@onready var default_player_stats := player_stats.to_dict()


func _ready() -> void:
	color_rect.color.a = 0


func change_scene(path: String, params := {}) -> void:
	var duration := params.get("duration", 0.2) as float

	var tree:= get_tree()
	tree.paused = true

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 1, duration)
	await tween.finished

	if tree.current_scene is World:
		var old_name := tree.current_scene.scene_file_path.get_file().get_basename()
		world_stats[old_name] = tree.current_scene.to_dict()

	#if "init" in params:
		#params.init.call()

	# change_scene_to_file会先摘除旧场景，但是不会立即释放，等到这一帧末尾再统一销毁，所以call init需要在这个前面执行，否则访问不到场景树
	tree.change_scene_to_file(path)

	# 如果非要放到这里，可以修改panel中，查看 @tree_exited 的注释
	if "init" in params:
		params.init.call()

	await tree.tree_changed

	if tree.current_scene is World:
		var new_name := tree.current_scene.scene_file_path.get_file().get_basename()

		if new_name in world_stats:
			tree.current_scene.from_dict(world_stats[new_name])

		if "entry_point" in params:
			for node in tree.get_nodes_in_group("entry_points"):
				if node.name == params.entry_point:
					tree.current_scene.update_player(node.global_position, node.direction)
					break

		if "position" in params and "direction" in params:
			tree.current_scene.update_player(params.position, params.direction)

	tree.paused = false

	tween = create_tween()
	# 如果没有这个，黑屏没有消失情况下按新的故事会闪烁，旧的新的都能显示
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 0, duration)


func save_game() -> void:
	var scene := get_tree().current_scene
	var scene_name := scene.scene_file_path.get_file().get_basename()
	world_stats[scene_name] = scene.to_dict()

	var data := {
		world_stats = world_stats,
		stats = player_stats.to_dict(),
		scene = scene.scene_file_path,
		player = {
			direction = scene.player.direction,
			position = {
				x = scene.player.global_position.x,
				y = scene.player.global_position.y,
			}
		}
	}

	var json := JSON.stringify(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if not file:
		return

	file.store_string(json)


func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if not file:
		return

	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Dictionary

	change_scene(data.scene, {
		direction = data.player.direction,
		position = Vector2(
			data.player.position.x,
			data.player.position.y

		),
		init = func():
			world_stats = data.world_stats
			player_stats.from_dict(data.stats)
	})


func new_game() -> void:

	change_scene("res://maps/forest.tscn", {
		duration = 1.0,
		init = func():
			world_stats = {}
			player_stats.from_dict(default_player_stats)
	})


func back_to_title() -> void:
	change_scene("res://scenes/title_screen.tscn", {
		duration = 1.0
	})


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

extends Node

# 障碍需要在代码重生成，因此需要preload
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/bird.tscn")

var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles: Array
var bird_heights := [200, 390]

const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var high_score: int = 0
var score: int
const SCORE_MODIFIER: int = 10
var difficulty
const MAX_DIFFICULTY: int = 2
var speed: float
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
const SPEED_MODIFIER: int = 5000
var screen_size: Vector2i
var ground_height: int
var game_running: bool
var last_obs

func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	difficulty = 0
	get_tree().paused = false
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

func _physics_process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		generate_obs()
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		score += speed
		show_score()
		# update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)
	adjust_difficulty( )

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			var obs = obs_type.instantiate()
			# 生成障碍了要放到合适的位置
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x: int = screen_size.x + score + 100 + i * 100
			var obs_y: int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		 # spawn bird!!!
		if difficulty == MAX_DIFFICULTY:
			var max_value = 100
			var threshold = 30  # 阈值，这里设置为 20，概率为 20%
			var random_num2 = randi() % max_value
			if random_num2 < threshold:
				var obs = bird_scene.instantiate()
				var obs_x: int = screen_size.x + score + 100
				var obs_y: int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	# 这样就可以连接了，不需要去对应的tscn里一个个加
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func adjust_difficulty():
	difficulty = score / SCORE_MODIFIER / 1000
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "Dino":
		game_over()

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

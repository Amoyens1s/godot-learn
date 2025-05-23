extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	hide()
	set_process_input(false)
	SoundManager.stop_sfx("Run")
	SoundManager.stop_sfx("EnemyRun")


func _input(event: InputEvent) -> void:
	get_window().set_input_as_handled()

	if animation_player.is_playing():
		return

	if (
		event is InputEvent or
		event is InputEventMouseButton or
		event is InputEventJoypadButton

	):
		# event.is_echo 是屏蔽回显事件，回西安比如按住D不动，就会一直输入D，这个重复发送就是回显
		if event.is_pressed() and not event.is_echo():
			if Game.has_save():
				Game.load_game()
			else:
				Game.back_to_title()


func show_game_over() -> void:
	show()
	set_process_input(true)
	animation_player.play("enter")
	SoundManager.play_bgm(preload("res://bgm/15 game over LOOP.ogg"))

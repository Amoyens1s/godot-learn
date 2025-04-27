extends Control


func _ready() -> void:
	hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	get_window().set_input_as_handled()

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

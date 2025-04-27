extends Control

@onready var v: VBoxContainer = $V
@onready var new_game: Button = $V/NewGame


func _ready() -> void:
	new_game.grab_focus()

	for button: Button in v.get_children():
		button.mouse_entered.connect(button.grab_focus)

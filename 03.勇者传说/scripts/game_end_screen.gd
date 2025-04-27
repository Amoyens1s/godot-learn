extends Control

const LINES := [
	"大野猪终于被打败了",
	"现在你是真正的勇者了",
	"话说你吃过野猪肉吗",
	"欸？我吗？我也没吃过",
	"不过我吃过野猪酱"
]

var current_line := -1
var tween: Tween

@onready var label: Label = $Label


func _ready() -> void:
	
	print("111")

	show_line(0)


func _input(event: InputEvent) -> void:
	if tween.is_running():
		return

	if (
		event is InputEvent or
		event is InputEventMouseButton or
		event is InputEventJoypadButton

	):
		# event.is_echo 是屏蔽回显事件，回西安比如按住D不动，就会一直输入D，这个重复发送就是回显
		if event.is_pressed() and not event.is_echo():
			if current_line + 1 < LINES.size():
				show_line(current_line + 1)
			else:
				Game.back_to_title()


func show_line(line: int) -> void:
	current_line = line

	tween = create_tween()
	# 渐入渐出，缓动曲线
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	if line > 0:
		tween.tween_property(label, "modulate:a", 0, 0.2)
	else:
		label.modulate.a = 0

	# 动画完成后要修改文字
	tween.tween_callback(label.set_text.bind(LINES[line]))

	# 文字慢慢显示出来
	tween.tween_property(label, "modulate:a", 1, 0.2)

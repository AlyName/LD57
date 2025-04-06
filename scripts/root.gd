extends Node2D
class_name Root

static var instance: Root

const speed_factor: float = 1.0

var global_time: float = 0.0
var height
var width

func _init() -> void:
	instance = self

func _ready() -> void:
	height = DisplayServer.window_get_size().y
	width = DisplayServer.window_get_size().x
	Controller.instance.state = Controller.REALINIT
	Controller.instance.init_state(Controller.instance.state)
	AudioManager.instance.play_bgm("bgm")

func new_tween():
	return get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)

func update_global_time(delta: float) -> void:
	global_time += delta

func _process(delta: float) -> void:
	update_global_time(delta)

func clear_dia_box() -> void:
	for child in get_children():
		if child is DiaBox:
			child.queue_free()

func clear_sprite2d() -> void:
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			child.queue_free()

func clear_special() -> void:
	for child in get_node("Special").get_children():
		child.queue_free()

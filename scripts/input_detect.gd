extends Node2D
class_name InputDetect

static var instance: InputDetect

const MOUSE_COLLID_R: float = 30.0
var is_focus_window: bool = false
var mouse_pos: Vector2 = Vector2.ZERO
var mouse_focus: Node2D = null

func _init() -> void:
	instance = self

func _process(_delta: float) -> void:
	mouse_detect()
	keyboard_detect()
## update mouse pos
func mouse_detect() -> void:
	mouse_pos = get_viewport().get_mouse_position()
	is_focus_window = get_window().has_focus()
	# ------
	var n_mouse_pos = get_viewport().get_mouse_position()
	# TODO : mouse outside of viewport
	if get_viewport().get_visible_rect().has_point(n_mouse_pos):
		mouse_pos = n_mouse_pos
	else:
		mouse_pos = Vector2(get_viewport().get_visible_rect().size.x/2, get_viewport().get_visible_rect().size.y/2)
	# get mouse focus in children of Main, which is the nearest node to mouse_pos
	var min_dis = MOUSE_COLLID_R
	mouse_focus = null
	for child in Main.instance.get_children():
		if can_be_touched(child):
			var dis = (mouse_pos+Camera.instance.position\
					- get_viewport().get_visible_rect().size/2\
					- child.get_global_position()).length()
			if dis < min_dis:
				min_dis = dis
				mouse_focus = child

func can_be_touched(node: Node) -> bool:
	return node is Block

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			pass
		else:
			Controller.instance.handle_input("click")

func keyboard_detect() -> void:
	if Input.is_action_just_pressed("cheat_forward"):
		Controller.instance.handle_input("cheat_forward")
	elif Input.is_action_just_pressed("cheat_backward"):
		Controller.instance.handle_input("cheat_backward")

extends Block
class_name BlockDir

const MOVE_X = [1, 0, -1, 0]
const MOVE_Y = [0, -1, 0, 1]
var n_tween: Tween
var dir: int # 0 - right, 1 - up, 2 - left, 3 - down
var last_dir: int
var abs_dir: int

func _init() -> void:
	pass

func rotate_ccw() -> void:
	dir = (dir + 1) % 4
	abs_dir = abs_dir + 1

func rotate_cw() -> void:
	dir = (dir - 1) % 4
	abs_dir = abs_dir - 1

func _process(delta: float) -> void:
	super._process(delta)
	handle_dir()

func handle_dir() -> void:
	if last_dir != dir:
		if n_tween != null:
			n_tween.kill()
		n_tween = Root.instance.new_tween()
		n_tween.tween_property(pattern, "rotation", -abs_dir * PI / 2, DT)
		last_dir = dir

func construct_misc(misc: Dictionary) -> void:
	super.construct_misc(misc)
	if misc.has("dir"):
		dir = misc["dir"]
		abs_dir = dir

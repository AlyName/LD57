extends Block
class_name BlockFish

var dir = 1
var eaten: bool = false

func _init() -> void:
	pass

func activate_move() -> bool:
	if eaten:
		return false
	if energy_num > 0:
		energy_num -= 1
		var tx = b_pos.x + dir
		var ty = b_pos.y
		var block = Main.instance.get_block_by_pos(Vector2(tx, ty))
		if block != null:
			block.add_energy(1)
			var blocks = [self, block]
			var new_poses = [Vector2(tx, ty), Vector2(tx-1, ty)]
			Main.instance.change_block_pos(blocks, new_poses)
		return true
	return false

func _process(delta: float) -> void:
	super._process(delta)
	pattern.scale = Vector2(dir, 1.0)

func eat() -> void:
	eaten = true
	pattern.hide()

func construct_misc(misc: Dictionary) -> void:
	super.construct_misc(misc)
	if misc.has("dir"):
		dir = 1 if misc["dir"] == 1 else -1
		


extends Block
class_name BlockRotate

const ROT_X: Array = [1,1,1,0,-1,-1,-1,0]
const ROT_Y: Array = [1,0,-1,-1,-1,0,1,1]

func _init() -> void:
	pass

func activate_move() -> bool:
	if energy_num > 0:
		energy_num -= 1
		var blocks: Array = []
		for i in range(8):
			var block = Main.instance.get_block_by_pos(Vector2(b_pos.x + ROT_X[i], b_pos.y + ROT_Y[i]))
			if block != null:
				blocks.append(block)
		var new_poses: Array = []
		for i in range(len(blocks)):
			new_poses.append(blocks[(i+1)%len(blocks)].b_pos)
		Main.instance.change_block_pos(blocks, new_poses)
		return true
	return false


extends Block
class_name BlockUmbrella

func _init() -> void:
	pass

func activate_move() -> bool:
	# is_hidden = false
	# energy_num += 2
	if energy_num > 0:
		energy_num -= 1
		var tx = b_pos.x
		var ty = b_pos.y - 1
		var block = Main.instance.get_block_by_pos(Vector2(tx, ty))
		if block != null:
			block.add_energy(1)
			var blocks = [self, block]
			var new_poses = [Vector2(tx, ty), Vector2(tx, ty+1)]
			Main.instance.change_block_pos(blocks, new_poses)
		return true
	return false

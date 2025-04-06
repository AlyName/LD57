extends BlockDir
class_name BlockLight

func _init() -> void:
	pass

func activate_move():
	if energy_num > 0:
		energy_num -= 1
		var x = b_pos.x + MOVE_X[dir]
		var y = b_pos.y + MOVE_Y[dir]
		var block = Main.instance.get_block_by_pos(Vector2(x, y))
		if block != null:
			block.add_energy(1)
			ParticleManager.instance.create_particle("1", block.position)
			block.spark()
		rotate_ccw()
		return true
	return false

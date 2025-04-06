extends BlockDir
class_name BlockArrow

func _init() -> void:
	pass

func activate_move():
	if energy_num > 0:
		energy_num -= 1
		for i in range(1,3):
			var x = b_pos.x + MOVE_X[dir] * i
			var y = b_pos.y + MOVE_Y[dir] * i
			var block = Main.instance.get_block_by_pos(Vector2(x, y))
			if block != null:
				block.add_energy(1)
				ParticleManager.instance.create_particle("1", block.position)
				block.spark()
		return true
	return false

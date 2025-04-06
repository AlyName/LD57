extends Block

class_name BlockBulb

func _init():
	pass

const TX = [1,-1,0,0]
const TY = [0,0,1,-1]

func activate_move()-> bool:
	if energy_num > 0:
		energy_num -= 1
		for i in range(4):
			var tx = TX[i]
			var ty = TY[i]
			var b = Main.instance.get_block_by_pos(b_pos + Vector2(tx, ty))
			if b:
				b.add_energy(1)
				ParticleManager.instance.create_particle("1", b.position)
				b.spark()
		return true
	return false

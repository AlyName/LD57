extends BlockDir

class_name BlockLadder

func _init():
	pass

func activate_move():
	if energy_num > 0:
		energy_num -= 1
		var x = b_pos.x + MOVE_X[dir]
		var y = b_pos.y + MOVE_Y[dir]
		var block = Main.instance.get_block_by_pos(Vector2(x, y))
		if block != null:
			var px = MOVE_X[(dir+1)%4]
			var py = MOVE_Y[(dir+1)%4]
			# 将 block 对应一行（一列）循环移位
			# step 1. 获取 block 所在行或列的全体元素
			var n_array = [block]
			var nx = int(block.b_pos.x + px + Main.instance.height) % Main.instance.height
			var ny = int(block.b_pos.y + py + Main.instance.width) % Main.instance.width
			# print(nx,ny)
			while not (nx == int(block.b_pos.x) and ny == int(block.b_pos.y)):
				n_array.append(Main.instance.get_block_by_pos(Vector2(nx, ny)))
				nx = (nx + px + Main.instance.height) % Main.instance.height
				ny = (ny + py + Main.instance.width) % Main.instance.width
				# print(nx,ny)
			# step 2. 将 n_array 中的元素按 dir 方向循环移位
			var new_poses = []
			for i in range(len(n_array)):
				new_poses.append(n_array[(i + 1) % len(n_array)].b_pos)
			Main.instance.change_block_pos(n_array, new_poses)
		return true
	return false

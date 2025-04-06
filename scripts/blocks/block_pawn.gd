extends Block
class_name BlockPawn

var is_broken: bool = false

func _init() -> void:
	pass

func activate_move() -> bool:
	return false

func add_energy(n_num: int) -> void:
	super.add_energy(n_num)
	if energy_num >= 2:
		if !is_broken:
			break_up()

func attack() -> void:
	if energy_num == 0 || is_broken:
		return
	Main.instance.lock_board()
	var victim = Main.instance.get_block_by_pos(b_pos + Vector2(-1,0))
	if victim != null and victim.energy_num > 0:
		await get_tree().create_timer(0.5).timeout
		var n_tween = Root.instance.new_tween()
		n_tween.tween_property(pattern, "position", 60 * (victim.b_pos - b_pos), 0.5)
		n_tween.tween_interval(0.5)
		n_tween.tween_callback(func():
			victim.energy_num -= 1
			AudioManager.instance.play_sfx("burst")
			victim.spark()
			ParticleManager.instance.create_particle("2", victim.position, 32)
			)
		n_tween.tween_interval(0.5)
		n_tween.tween_property(pattern, "position", Vector2(0, 0), 0.5)
		await n_tween.finished
	Main.instance.unlock_board()

func break_up() -> void:
	is_broken = true
	ParticleManager.instance.create_particle("2", position, 32)
	pattern.hide()

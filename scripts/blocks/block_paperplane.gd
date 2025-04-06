extends Block

class_name BlockPaperPlane

func _init():
	pass

func _ready() -> void:
	super._ready()
	star_bar.visible = false

func first_show() -> void:
	if Main.instance.current_level is Level2:
		Main.instance.current_level.add_collision(Vector2(0, b_pos.y), Main.instance.now_round + 10)
	await Root.instance.get_tree().create_timer(1).timeout
	var particle_small = load("res://scenes/particle_small.tscn").instantiate()
	particle_small.amount = 64
	pattern.add_child(particle_small)
	# pattern move out of the box
	var tween = Root.instance.create_tween()
	var dest_pos = pattern.position + Vector2(1000, -1200)
	tween.tween_property(pattern, "position", dest_pos, 5)
	tween.tween_callback(func():
		pattern.visible = false
		particle_small.queue_free()
		)

	var t_tween = Root.instance.create_tween()
	t_tween.tween_interval(5)
	t_tween.tween_callback(func():
		var rev_plane = Sprite2D.new()
		rev_plane.texture = load("res://imgs/paperplanefly.png")
		rev_plane.z_index = -5
		rev_plane.scale = Vector2(-1,1)
		rev_plane.modulate = Color(0.2,0.2,0.2,1)
		rev_plane.position = Vector2(1000,randf_range(-300,300))
		rev_plane.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var i_particle_small = load("res://scenes/particle_small.tscn").instantiate()
		i_particle_small.amount = 64
		i_particle_small.modulate = Color(0.7,0.7,0.7,1)
		rev_plane.add_child(i_particle_small)
		Root.instance.add_child(rev_plane)
		var i_tween = Root.instance.create_tween()
		i_tween.tween_property(rev_plane, "position", Vector2(-1000,rev_plane.position.y+randf_range(-50,50)), 12)
		i_tween.tween_callback(func():
			rev_plane.queue_free()
			)
	)

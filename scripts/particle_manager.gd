extends Node2D
class_name ParticleManager

static var instance: ParticleManager

var scene_in_foreground: Node2D

func _ready() -> void:
	instance = self
	scene_in_foreground = Node2D.new()
	scene_in_foreground.z_index = 200
	add_child(scene_in_foreground)

func clear_particles() -> void:
	for child in get_children():
		if child is GPUParticles2D:
			child.queue_free()

func create_particle(type: String, pos: Vector2, num: int=16) -> Node2D:
	if type == "1":
		var particle_1 = preload("res://scenes/particle_1.tscn").instantiate()
		particle_1.position = pos
		particle_1.num_particles = num
		particle_1.repeat = false
		add_child(particle_1)
		return particle_1
	elif type == "2":
		var particle_2 = preload("res://scenes/particle_2.tscn").instantiate()
		particle_2.position = pos
		particle_2.num_particles = num
		particle_2.repeat = false
		add_child(particle_2)
		return particle_2
	elif type == "constant":
		var particle_constant = preload("res://scenes/particle_constant.tscn").instantiate()
		particle_constant.position = pos
		particle_constant.amount = num
		add_child(particle_constant)
		return particle_constant
	return null

func change_scene_in() -> void:
	# 转场 8s
	for child in scene_in_foreground.get_children():
		child.queue_free()
	scene_in_foreground.visible = true
	for i in range(-64,65):
		for j in range(-36,37):
			var ball = Sprite2D.new()
			ball.texture = load("res://imgs/ball.png")
			ball.position = Vector2(i, j) * 25
			ball.modulate = Color(0,0,0,1)
			ball.scale = Vector2(0,0)
			scene_in_foreground.add_child(ball)
			var ball_tween = create_tween()
			ball_tween.tween_interval((i+64+j+36)*0.03)
			ball_tween.tween_property(ball, "scale", Vector2(1,1), 1.0)
	await get_tree().create_timer(8.0).timeout

func change_scene_out() -> void:
	# 转场 1s
	for child in scene_in_foreground.get_children():
		child.queue_free()
	var black_fade = Sprite2D.new()
	black_fade.texture = load("res://imgs/dot.png")
	black_fade.z_index = 100
	black_fade.scale = Vector2(1,1) * 200
	black_fade.modulate = Color(0,0,0,1)
	scene_in_foreground.add_child(black_fade)
	var black_fade_tween = create_tween()
	black_fade_tween.tween_property(black_fade, "modulate", Color(0,0,0,0), 1.0)
	await black_fade_tween.finished
	black_fade.queue_free()
	scene_in_foreground.visible = false

func change_scene_in_white() -> void:
	# 转场 8s
	for child in scene_in_foreground.get_children():
		child.queue_free()
	var white_fg = Sprite2D.new()
	white_fg.texture = load("res://imgs/white_bg.png")
	white_fg.z_index = 100
	white_fg.scale = Vector2(1,1)
	white_fg.modulate = Color(1,1,1,0)
	add_child(white_fg)
	
	var white_fg_tween = create_tween()
	white_fg_tween.tween_property(white_fg, "modulate", Color(1,1,1,1), 8.0)
	await white_fg_tween.finished

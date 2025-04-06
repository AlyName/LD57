extends Camera2D
class_name Camera

static var instance: Camera

func _init() -> void:
	instance = self

func shake(strength: float) -> void:
	var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	position = offset

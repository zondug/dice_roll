extends Resource
class_name DicePool

var dice_faces = {}

func _init():
	register_default_faces()

func register_default_faces():
	dice_faces = {
		"attack": preload("res://DiceFaces/attack.png"),
		"shield": preload("res://DiceFaces/shield.png"),
		"skill": preload("res://DiceFaces/skill.png"),
		"magic": preload("res://DiceFaces/magic.png")
	}

func get_faces() -> Array:
	return dice_faces.values()

func get_face_name(texture: Texture2D) -> String:
	for face_name in dice_faces:
		if dice_faces[face_name] == texture:
			return face_name
	return ""

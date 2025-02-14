extends RigidBody2D

@onready var icon_attack = preload("res://DiceFaces/attack.png")
@onready var icon_shield = preload("res://DiceFaces/shield.png")
@onready var icon_skill = preload("res://DiceFaces/skill.png")
@onready var icon_magic = preload("res://DiceFaces/magic.png")
@onready var dice_faces = [icon_attack, icon_shield, icon_skill, icon_magic]

@export_group("Dice Face Change Settings")
@export var min_face_change_interval: float = 1.5  # minimum face change interval
@export var max_face_change_interval: float = 0.8  # maximum face change interval
@export var speed_scale_factor: float = 1000.0      # scale factor of speed

@export_group("Scale Animation Settings")
@export var max_scale_multiplier: float = 1.5  # maximum scale multiplier 
@export var scale_animation_duration: float = 0.5  # scale animation duration

var DiceSize = Vector2(200, 200)
var is_rolling = false
var next_face_change = 0.0
var original_dice_scale: Vector2

func _ready():
	gravity_scale = 0.0
	linear_damp = 4.0
	angular_damp = 3.0
	
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.2
	physics_material.friction = 0.5
	physics_material_override = physics_material
	
	$DiceFrame.scale = DiceSize/$DiceFrame.texture.get_size()
	$DiceFace.scale = DiceSize/$DiceFace.texture.get_size() * 0.9
	original_dice_scale = scale
	new_face()

func _physics_process(delta):
	if is_rolling:
		var speed = linear_velocity.length()
		next_face_change -= delta
		
		if speed > 20 and next_face_change <= 0:
			new_face()
			next_face_change = randf_range(min_face_change_interval, max_face_change_interval) * \
							 (speed_scale_factor / (speed + speed_scale_factor/2.0))

func roll_the_dice():
	is_rolling = true
	next_face_change = 0.0
	
	# wait for scale animation
	var tween = animate_scale()
	await tween.finished
	
	# wait for initial deceleration
	while linear_velocity.length() > 50:
		await get_tree().create_timer(0.1).timeout
	
	# apply force for additional rolling after landing
	var current_velocity = linear_velocity
	var velocity_magnitude = current_velocity.length()
	var direction = current_velocity.normalized()

	# change direction within ±5% of current direction
	var angle_deviation = randf_range(-0.05, 0.05) * PI  # ±5% = ±0.05 * π radian
	var rotated_direction = direction.rotated(angle_deviation)

	# speed also varies within ±5% of current direction
	var speed_variation = velocity_magnitude * randf_range(0.95, 1.05)
	var random_roll_force = rotated_direction * speed_variation

	apply_impulse(random_roll_force)
	apply_torque_impulse(randf_range(-500, 2000))
	
	# wait for the dice to completely stop
	while linear_velocity.length() > 20 or abs(angular_velocity) > 0.5:
		await get_tree().create_timer(0.1).timeout
	
	var final_face = new_face()
	is_rolling = false
	return final_face

func animate_scale():
	var tween = create_tween()
	
	# generate random values for each dice
	var random_scale = randf_range(max_scale_multiplier * 0.8, max_scale_multiplier * 1.1)
	var random_duration_up = randf_range(scale_animation_duration * 0.4, scale_animation_duration * 0.6)
	var random_duration_down = randf_range(scale_animation_duration * 0.4, scale_animation_duration * 0.6)
	
	# scale animation
	tween.tween_property(self, "scale", original_dice_scale * random_scale, random_duration_up)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# scale back to original size
	tween.tween_property(self, "scale", original_dice_scale, random_duration_down)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	return tween


func new_face():
	var the_face = dice_faces[randi_range(0, dice_faces.size()-1)]
	$DiceFace.texture = the_face
	$DiceFace.scale = DiceSize/$DiceFace.texture.get_size() * 0.9
	return the_face

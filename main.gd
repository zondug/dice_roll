extends Node2D

@export var hit_force: float = 5000.0
@export var dice_count: int = 5
@export var dice_spacing: float = 250.0

var dice_list = []

func _ready():
	setup()

func reset_dices():
	for dice in dice_list:
		dice.queue_free()
	dice_list.clear()

func setup():
	reset_dices()
	var start_pos = $Camera2D.get_screen_center_position() - Vector2((dice_count - 1) * dice_spacing / 2, 0)
	
	for i in range(dice_count):
		var dice = preload("res://Dice.tscn").instantiate()
		add_child(dice)
		dice.position = start_pos + Vector2(i * dice_spacing, 0)
		dice_list.append(dice)

func _on_button_pressed():
	setup()
	for dice in dice_list:
		if not dice.is_rolling:
			# generate random direction (0 to 2π radian)
			var random_angle = randf() * 2 * PI
			var direction = Vector2(cos(random_angle), sin(random_angle))
			
			# also vary the force size (80%~120% range)
			var force_variation = randf_range(0.8, 1.2)
			var throw_force = direction * hit_force * force_variation
			
			dice.apply_impulse(throw_force)
			# also add torque
			dice.apply_torque_impulse(randf_range(-1000, 2000))
			dice.roll_the_dice()

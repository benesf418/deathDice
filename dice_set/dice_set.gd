extends Node3D
class_name DiceSet

var dice_list: Array[Dice]
var dice_values: Dictionary

var combo: DiceCombo = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for dice in $dice.get_children():
		dice_list.push_back(dice)
		dice_values[dice.name] = -1
		dice.throw_finished.connect(dice_throw_finished)

func _input(delta):
	if Input.is_action_pressed("reset_dice"):
		for dice in dice_list:
			if !dice.resetable:
				return
		for dice in dice_list:
			dice.reset()
		for key in dice_values.keys():
			dice_values[key] = -1
	if Input.is_action_pressed("m_left_pressed"):
		for dice in dice_list:
			if !dice.throwable:
				return
		for dice in dice_list:
			dice.throw()

func get_throw_combo():
	var values: Array[int]
	for value in dice_values.values():
		values.push_back(value)
	
	var counts: Array[int]
	
	#get counts
	for i in range(1, 7):
		counts.push_back(0)
		for value in values:
			if value == i:
				counts[i-1] += 1
	
	var new_combo = DiceCombo.new(counts)
	if combo != null:
		print(new_combo.compare(combo))
	combo = new_combo

func dice_throw_finished(dice_name:String, value:int):
	dice_values[dice_name] = value
	for key in dice_values.keys():
		if  dice_values[key] == -1:
			return
	get_throw_combo()

extends Node3D
class_name DiceSet

var dice_list: Array[Dice]
var dice_values: Dictionary
var combo: DiceCombo = null

var second_throw: bool = false

#assigned by parent on ready
var board: Board

func _ready():
	for dice in $dice.get_children():
		dice_list.push_back(dice)
		dice_values[dice.name] = -1
		dice.throw_finished.connect(on_dice_throw_finished)
		dice.prediction_throw_finished.connect(on_dice_prediction_throw_finished)
		dice.reseted.connect(on_dice_reseted)

func set_board(board:Board):
	var dice_index = 0
	for dice in dice_list:
		dice.resting_position = board.resting_positions[dice_index].global_position
		dice_index += 1

func reset():
	for dice in dice_list:
			if !dice.resetable:
				return
	
	for dice in dice_list:
		if !dice.is_rested or second_throw:
			dice.reset()
	
	for key in dice_values.keys():
		if !get_node("dice/"+key).is_rested:
			dice_values[key] = -1
	
	if !second_throw:
		second_throw = true
	else:
		second_throw = false

func predict_throw():
	for dice in dice_list:
		dice.throw(1, true)

func throw(predict_first = true):
	for dice in dice_list:
		if !dice.throwable and !dice.is_rested:
			return
	
	for dice in dice_list:
		if !dice.is_rested:
			dice.throw(1, predict_first)

func get_throw_combo():
	var values: Array[int]
	for value in dice_values.values():
		values.push_back(value)
	
	var counts: Array[int]
	
	#get counts for 1-6 dice values
	for i in range(1, 7):
		counts.push_back(0)
		for value in values:
			if value == i:
				counts[i-1] += 1
	
	var new_combo = DiceCombo.new(counts)
	if combo != null:
		print(new_combo.compare(combo))
	combo = new_combo

func on_dice_throw_finished(dice_name:String, value:int):
	dice_values[dice_name] = value
	for key in dice_values.keys():
		if  dice_values[key] == -1:
			return
	for dice in dice_list:
		dice.rest()
	get_throw_combo()

func on_dice_prediction_throw_finished():
	for dice in dice_list:
#		dice.visible = false
		if dice.prediction_in_process:
			return
	for dice in dice_list:
		dice.visible = true
	throw(false)

func on_dice_reseted(dice_name:String):
	dice_values[dice_name] = -1

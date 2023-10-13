extends Node3D

@export var board : Board

func _ready():
	$DiceSet.set_board(board)

func _on_player_controls_throw():
	$DiceSet.throw()

func _on_player_controls_reset():
	$DiceSet.reset()


func _on_player_controls_predict_throw():
	$DiceSet.predict_throw()

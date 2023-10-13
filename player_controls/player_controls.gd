extends Control

signal throw
signal reset
signal predict_throw

func _on_throw_button_button_up():
	emit_signal('throw')


func _on_reset_button_button_up():
	emit_signal('reset')


func _on_predict_throw_button_button_up():
	emit_signal('predict_throw')

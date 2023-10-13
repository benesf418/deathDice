extends RigidBody3D
class_name Dice

signal throw_finished
signal prediction_throw_finished
signal reseted

@export var wanted_numbers = [1, 2, 3, 4, 5, 6]

var freezable = false
var starting_position: Vector3
var starting_rotation: Vector3
var numberRaycasts: Array[RayCast3D]
var resetable: bool = false
var throwable: bool = true

var mouse_hover: bool = false

var resting_position: Vector3
var is_rested = false

var is_prediction = false
var prediction_in_process = false
var prediction_rot_adjustment = Vector3.ZERO

var throw_force: Vector3
var throw_vector: Vector3

func _ready():
	can_sleep = false
	numberRaycasts = [
		$Representation/detect1,
		$Representation/detect2,
		$Representation/detect3,
		$Representation/detect4,
		$Representation/detect5,
		$Representation/detect6
	]
	freeze = true
	starting_position = position
	starting_rotation = rotation
	reset()

#func _integrate_forces(state):
#	if Input.is_action_pressed("m_left_pressed"):
#		print('pica')
#		state.apply_force(Vector3.ZERO.rotated(Vector3(1, 0, 0), PI/2))

func _physics_process(delta):
	if linear_velocity.length() + angular_velocity.length() < 0.4 and freezable and !freeze:
		finish_throw()
	
	if mouse_hover and Input.is_action_just_released("m_left_pressed") and is_rested:
		reset()

func rest():
	global_position = resting_position
	is_rested = true

func finish_throw():
	freeze = true
	
	var finalNumber = -1
	var number = 1
	for numberRaycast in numberRaycasts:
		numberRaycast.force_raycast_update()
		if numberRaycast.get_collider() and numberRaycast.get_collider().name == 'boardCollisionArea':
			finalNumber = number
			resetable = true
			if not prediction_in_process:
				emit_signal('throw_finished', name, finalNumber)
			else:
				on_prediction_throw_finished(finalNumber)
		number += 1
	
	$throwTimer.wait_time = 0.1
	
	#wiggle if no number landed properly
	if finalNumber == -1:
		throw(0.3)

func reset(after_prediction = false):
	position = starting_position
	rotation = starting_rotation
	
	if !after_prediction:
		randomize()
		$Representation.rotation = Vector3.ZERO
		rotate_y(randi_range(0, 9)*PI/2)
		rotate_x(randi_range(0, 9)*PI/2)
		throw_force = Vector3(randf_range(-15, 15), randf_range(-100, -80), randf_range(-1400, -900))
		throw_vector = Vector3(randf_range(-0.3, 0.3), randf_range(0.25, 0.45), -1)
		starting_rotation = rotation
	else:
		$Representation.rotation = Vector3.ZERO
		if prediction_rot_adjustment != Vector3.ZERO:
			$Representation.rotate(prediction_rot_adjustment.normalized(), PI/2*prediction_rot_adjustment.length())
	
	resetable = false
	throwable = true
	is_rested = false
	emit_signal('reseted', name)

func throw(force:float = 1, prediction:bool = false):
	if prediction:
		prediction_in_process = true
		visible = false
	$throwTimer.start()
	freeze = false
	freezable = false
	throwable = false
	apply_force(
		Vector3(throw_force.x, throw_force.y, throw_force.z*force),
		throw_vector
	)

func _on_throw_timer_timeout():
	freezable = true
	$throwTimer.stop()

func _on_mouse_entered():
	mouse_hover = true

func _on_mouse_exited():
	mouse_hover = false

func on_prediction_throw_finished(predicted_number:int):
	var x_numbers = [2, 3, 5, 4]
	var y_numbers = [1, 5, 6, 2]
	var z_numbers = [1, 3, 6, 4]
	var wanted_number = wanted_numbers.pick_random()
	prediction_rot_adjustment = Vector3.ZERO
	if x_numbers.find(wanted_number) != -1 and x_numbers.find(predicted_number) != -1:
		prediction_rot_adjustment.x = x_numbers.find(wanted_number) - x_numbers.find(predicted_number)
	elif y_numbers.find(wanted_number) != -1 and y_numbers.find(predicted_number) != -1:
		prediction_rot_adjustment.y = y_numbers.find(wanted_number) - y_numbers.find(predicted_number)
	else:
		prediction_rot_adjustment.z = z_numbers.find(wanted_number) - z_numbers.find(predicted_number)
#	visible = true
	prediction_in_process = false
	reset(true)
	emit_signal('prediction_throw_finished')

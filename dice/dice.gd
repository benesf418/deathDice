extends RigidBody3D
class_name Dice

signal throw_finished

var freezable = false
var starting_position: Vector3
var starting_rotation: Vector3
var numberRaycasts: Array[RayCast3D]
var resetable: bool = false
var throwable: bool = true

var mouse_hover: bool = false

var resting_position: Vector3
var is_rested = false

func _ready():
	numberRaycasts = [
		$detect1,
		$detect2,
		$detect3,
		$detect4,
		$detect5,
		$detect6
	]
	freeze = true
	starting_position = position
	starting_rotation = rotation
	reset()

func _physics_process(delta):
	if linear_velocity.length() + angular_velocity.length() < 0.05 and freezable and !freeze:
		finish_throw()
	
	if mouse_hover and Input.is_action_pressed("m_left_pressed") and resetable:
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
			emit_signal('throw_finished', name, finalNumber)
		number += 1
	
	$throwTimer.wait_time = 0.1
	
	#wiggle if no number landed properly
	if finalNumber == -1:
		var x = randi_range(0,1)
		if x == 0:
			throw(0.3)
		else:
			throw(-0.3)

func reset():
	position = starting_position
	rotation = starting_rotation
	randomize()
	rotate_y(randi_range(0, 6)*90)
	rotate_x(randi_range(0, 6)*90)
	resetable = false
	throwable = true
	is_rested = false

func throw(force:float = 1):
	$throwTimer.start()
	freeze = false
	freezable = false
	throwable = false
	apply_force(
		Vector3(randf_range(-15, 15), randf_range(-100, -80), randf_range(-1400, -900)*force),
		Vector3(randf_range(-0.3, 0.3), randf_range(0.25, 0.45), -1)
	)

func _on_throw_timer_timeout():
	freezable = true
	$throwTimer.stop()


func _on_mouse_entered():
	mouse_hover = true

func _on_mouse_exited():
	mouse_hover = false

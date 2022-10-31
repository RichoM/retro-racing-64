extends Spatial
class_name Car

onready var car_mesh = $mesh
onready var ball = $ball
onready var ground_ray = $mesh/ground_ray
onready var camera = $mesh/camera
onready var engine_sfx = $engine_sfx

onready var wheel_back_left = $mesh/body/wheel_back_left
onready var wheel_back_right = $mesh/body/wheel_back_right
onready var wheel_front_left = $mesh/body/wheel_front_left
onready var wheel_front_right = $mesh/body/wheel_front_right

onready var wheels = [wheel_back_left, wheel_back_right,
					wheel_front_left, wheel_front_right]
					
var ball_speed = 0
					
var sphere_offset = Vector3(0, -1.5, 0)
var speed_input = 0
var rotate_input = 0

var acceleration = 0.9
var steering = 35
var turn_speed = 3.00
var turn_stop_limit = 0.75
var body_tilt = 135

var input_enabled = false

var checkpoints = []
var laps = 0
var track_begin = 0
var lap_begin = 0
var cur_time = 0
var last_time = 0
var best_time = INF
var tot_time = 0

signal lap_completed(lap_counter, lap_time, total_time)


func rotate_for_display(delta):
	rotate_object_local(Vector3.UP, 0.5 * delta)
	for wheel in wheels:
		wheel.rotate_object_local(Vector3.LEFT, 5 * delta)

func _ready():
	ground_ray.add_exception(ball)

func _process(delta):
	if track_begin > 0: 
		var now = OS.get_ticks_msec()
		tot_time = now - track_begin
		cur_time = now - lap_begin
	
	ball_speed = ball.linear_velocity.length()
			
	if camera:
		var b : RigidBody = ball
		camera.h_offset = lerp(camera.h_offset, -rotate_input, 0.5)
		camera.fov = lerp(50, 100, b.linear_velocity.length() / 60)
		camera.fov = min(camera.fov, 100)
		
	if engine_sfx:
		engine_sfx.pitch_scale = lerp(0.01, 1.0, ball_speed / 60)
		engine_sfx.pitch_scale = min(engine_sfx.pitch_scale, 2)
		engine_sfx.volume_db = lerp(-20, 0, engine_sfx.pitch_scale/1.5) + 5
	
	var collider : Node = ground_ray.get_collider()
	if collider && collider.is_in_group("grass"):
		acceleration = 0.85
	else:
		acceleration = 0.9
	speed_input *= acceleration
	
	if not input_enabled: return
	
	# Can't steer/accelerate when in the air
	if not ground_ray.is_colliding(): return
	
	# f/b input
	#speed_input = 0
	speed_input += Input.get_action_strength("accelerate") * 35
	speed_input -= Input.get_action_strength("brake") * 10
	
	# steer input
	var steer_left = Input.get_action_strength("steer_left") * 3.5
	var steer_right = Input.get_action_strength("steer_right") * 3.5
	if steer_left == 0 and steer_right == 0:
		if rotate_input > 0:
			rotate_input -= deg2rad(2.5)
			rotate_input = max(rotate_input, 0)
		elif rotate_input < 0:
			rotate_input += deg2rad(2.5)
			rotate_input = min(rotate_input, 0)
	else:
		rotate_input += deg2rad(steer_left)
		rotate_input -= deg2rad(steer_right)
		rotate_input = clamp(rotate_input, -1.2, 1.2)
		
	# rotate wheels for effect
	var wheel_rotation = rotate_input * deg2rad(steering)
	wheel_front_right.rotation.z = -wheel_rotation
	wheel_front_left.rotation.z = -wheel_rotation
		
	# rotate car mesh
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_rotation = (rotate_input if speed_input >= 0 else -rotate_input) * deg2rad(steering)
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, new_rotation)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		
		
		# tilt body for effect
		#var t = -rotate_input * ball.linear_velocity.length() / body_tilt
		#$mesh/body.rotation.z = lerp($mesh/body.rotation.z, t, 10 * delta)
	
	# align mesh with ground normal
	var n = ground_ray.get_collision_normal()
	var xform = align_with_y(car_mesh.global_transform, n.normalized())
	car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)
	
func _physics_process(delta):
	#car_mesh.transform.origin = ball.transform.origin + sphere_offset
	
	# just lerp the y due to trimesh bouncing
	car_mesh.transform.origin.x = ball.transform.origin.x + sphere_offset.x
	car_mesh.transform.origin.z = ball.transform.origin.z + sphere_offset.z
	car_mesh.transform.origin.y = lerp(car_mesh.transform.origin.y, ball.transform.origin.y + sphere_offset.y, 0.5)
	
	#car_mesh.transform.origin = lerp(car_mesh.transform.origin, ball.transform.origin + sphere_offset, 0.3)
	var force = -car_mesh.global_transform.basis.z * speed_input * 20
	ball.add_central_force(force)
	
	

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
		


func entered_checkpoint(checkpoint : int, total : int):
	print("Enter checkpoint: ", checkpoint, "/", total)
	var now = OS.get_ticks_msec()
	
	if checkpoints.size() == 0:
		if checkpoint != 0:
			print("Wrong checkpoint!")
			return
	else:
		var last_checkpoint = checkpoints.back()
		if checkpoint == 0 and last_checkpoint == total - 1:
			print("Lap end!")
			laps += 1
			last_time = now - lap_begin
			if last_time < best_time: 
				best_time = last_time
			print("TIME: ", last_time)
			emit_signal("lap_completed", laps, last_time, tot_time)
			checkpoints.clear()
		elif checkpoint <= last_checkpoint or checkpoint - last_checkpoint != 1: 
			print("Wrong checkpoint!")
			return
	
	checkpoints.append(checkpoint)
	if checkpoints.size() == 1:
		print("Lap begin!")
		lap_begin = now
		if laps == 0:
			print("Track begin!")
			track_begin = now
	else:
		print("Checkpoint!")

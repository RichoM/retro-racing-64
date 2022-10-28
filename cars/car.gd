extends Spatial

onready var car_mesh = $mesh
onready var ball = $ball
onready var ground_ray = $mesh/ground_ray
onready var camera = $mesh/camera

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

func rotate_for_display(delta):
	rotate_object_local(Vector3.UP, 0.5 * delta)
	for wheel in wheels:
		wheel.rotate_object_local(Vector3.LEFT, 5 * delta)

func _ready():
	ground_ray.add_exception(ball)

func _process(delta):
	ball_speed = ball.linear_velocity.length()
	
	if camera:
		var b : RigidBody = ball
		camera.h_offset = lerp(camera.h_offset, -rotate_input, 0.5)
		camera.fov = lerp(50, 100, b.linear_velocity.length() / 50)
		camera.fov = min(camera.fov, 100)
	
	speed_input *= acceleration
	
	# Can't steer/accelerate when in the air
	if not ground_ray.is_colliding(): return
	
	# f/b input
	#speed_input = 0
	speed_input += Input.get_action_strength("accelerate") * 35
	speed_input -= Input.get_action_strength("brake") * 10
	
	# steer input
#	rotate_target = lerp(rotate_target, rotate_input, 5 * delta)
	#rotate_input = 0
	var steer_left = Input.get_action_strength("steer_left") * 2.5
	var steer_right = Input.get_action_strength("steer_right") * 2.5
	if steer_left == 0 and steer_right == 0:
		if rotate_input > 0:
			rotate_input -= deg2rad(2.5)
			rotate_input = max(rotate_input, 0)
		elif rotate_input < 0:
			rotate_input += deg2rad(2.5)
			rotate_input = min(rotate_input, 0)
		
	else:
		rotate_input += deg2rad(steer_left if speed_input >= 0 else steer_right)
		rotate_input -= deg2rad(steer_right if speed_input >= 0 else steer_left)
		rotate_input = clamp(rotate_input, -1.2, 1.2)
		
	# rotate wheels for effect
	var wheel_rotation = rotate_input * deg2rad(steering)
	if speed_input < 0: wheel_rotation *= -1
	wheel_front_right.rotation.z = -wheel_rotation
	wheel_front_left.rotation.z = -wheel_rotation
		
	# rotate car mesh
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_rotation = rotate_input * deg2rad(steering)
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
		

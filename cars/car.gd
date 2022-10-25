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
					
var sphere_offset = Vector3(0, -1, 0)
var speed_input = 0

var acceleration = 0.9
var steering = 25
var turn_speed = 2.5
var turn_stop_limit = 0.75
var body_tilt = 135

func rotate_for_display(delta):
	rotate_object_local(Vector3.UP, 0.5 * delta)
	for wheel in wheels:
		wheel.rotate_object_local(Vector3.LEFT, 5 * delta)

func _ready():
	ground_ray.add_exception(ball)

func _process(delta):
	# Can't steer/accelerate when in the air
	if not ground_ray.is_colliding():
		return
	# f/b input
	#speed_input = 0
	speed_input += Input.get_action_strength("accelerate") * 8
	speed_input -= Input.get_action_strength("brake") * 0.5
	speed_input *= acceleration
	# steer input
#	rotate_target = lerp(rotate_target, rotate_input, 5 * delta)
	var rotate_input = 0
	rotate_input += Input.get_action_strength("steer_left")
	rotate_input -= Input.get_action_strength("steer_right")
	rotate_input *= deg2rad(steering)
	
	# rotate wheels for effect
	wheel_front_right.rotation.z = -rotate_input
	wheel_front_left.rotation.z = -rotate_input
		
	# rotate car mesh
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, rotate_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		
		# tilt body for effect
		#var t = -rotate_input * ball.linear_velocity.length() / body_tilt
		#$mesh/body.rotation.z = lerp($mesh/body.rotation.z, t, 10 * delta)
		
	var t = ball.linear_velocity.length()
	#$mesh/body.rotation.z = lerp($mesh/body.rotation.z, t, 10 * delta)
	
	# align mesh with ground normal
	var n = ground_ray.get_collision_normal()
	var xform = align_with_y(car_mesh.global_transform, n.normalized())
	car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)
	
	if camera:
		var b : RigidBody = ball
		#camera.h_offset = -rotate_input * 1.5
		#camera.fov = lerp(60, 90, b.linear_velocity.length() / 75)
		#camera.fov = min(camera.fov, 90)
		
	
func _physics_process(delta):
	#car_mesh.transform.origin = ball.transform.origin
	
	# just lerp the y due to trimesh bouncing
#	car_mesh.transform.origin.x = ball.transform.origin.x + sphere_offset.x
#	car_mesh.transform.origin.z = ball.transform.origin.z + sphere_offset.z
#	car_mesh.transform.origin.y = lerp(car_mesh.transform.origin.y, ball.transform.origin.y + sphere_offset.y, 10 * delta)
	
	car_mesh.transform.origin = lerp(car_mesh.transform.origin, ball.transform.origin + sphere_offset, 0.3)
	
	ball.add_central_force(-car_mesh.global_transform.basis.z * speed_input * 0.85)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
		

extends Spatial

onready var car = $car
onready var animation = $AnimationPlayer

func _ready():
	animation.play("camera")

func _process(delta):
	$GUI/debug_labels/fps.text = "FPS: " + str(Engine.get_frames_per_second())
	$GUI/debug_labels/speed_input.text = "Speed: " + str(car.speed_input) + ", " + str(car.ball_speed)
	$GUI/debug_labels/rotate_input.text = "Rotation: " + str(car.rotate_input)
	$GUI/debug_labels/steer_left.text = "Left: " + str(Input.get_action_strength("steer_left"))
	$GUI/debug_labels/steer_right.text = "Right: " + str(Input.get_action_strength("steer_right"))


func _on_play_button_pressed():
	animation.stop()
	$GUI/title.hide()
	$GUI/play_button.hide()
	$GUI/onscreen_controls.show()
	$Camera.current = false
	car.camera.current = true

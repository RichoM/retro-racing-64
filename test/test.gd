extends Spatial

onready var car = $car
onready var animation = $AnimationPlayer

onready var lap_counter : Label = $GUI/game/left_col/lap_counter
onready var cur_time : Label = $GUI/game/right_col/cur_time
onready var last_time : Label = $GUI/game/right_col/last_time
onready var best_time : Label = $GUI/game/right_col/best_time

func _ready():
	animation.play("camera")
	$GUI/main.show()
	$GUI/game.hide()
	#$menu_music.play()

func _process(delta):
	show_debug_info()
	
	var player = car
	if player.cur_time:
		lap_counter.text = "LAP  " + str(player.laps + 1)
		cur_time.text = format(player.cur_time)
	else:
		lap_counter.text = ""
		cur_time.text = ""
	
	if player.laps > 0:
		last_time.text = "LAST " + format(player.last_time)
		best_time.text = "BEST " + format(player.best_time)
	else:
		last_time.text = ""
		best_time.text = ""
	
func show_debug_info():
	$GUI/game/debug_labels/fps.text = "FPS: " + str(Engine.get_frames_per_second())
	$GUI/game/debug_labels/speed_input.text = "Speed: " + str(car.speed_input) + ", " + str(car.ball_speed)
	$GUI/game/debug_labels/rotate_input.text = "Rotation: " + str(car.rotate_input)
	$GUI/game/debug_labels/steer_left.text = "Left: " + str(Input.get_action_strength("steer_left"))
	$GUI/game/debug_labels/steer_right.text = "Right: " + str(Input.get_action_strength("steer_right"))

func _on_play_button_pressed():
	animation.stop()
	$menu_music.stop()
	$GUI/main.hide()
	$GUI/game.show()
	$Camera.current = false
	car.camera.current = true
	car.engine_sfx.play()
	#$game_music.play()


func format(duration):
	var ms = floor(duration%1000)/10
	var s = floor((duration/1000)%60)
	var m = floor((duration/(1000*60))%60)
	return "%02d:%02d:%02d" % [m, s, ms]

func _on_car_new_record(new_time):
	print("NEW RECORD")
	# TODO(Richo): Show message

extends Spatial

onready var car = $car
onready var animation = $AnimationPlayer

onready var lap_counter : Label = $GUI/game/left_col/lap_counter
onready var tot_time : Label = $GUI/game/right_col/tot_time
onready var lap_completed : Label = $GUI/game/lap_completed
onready var lap1_time : Label = $GUI/game/right_col/lap1_time
onready var lap2_time : Label = $GUI/game/right_col/lap2_time
onready var lap3_time : Label = $GUI/game/right_col/lap3_time
onready var lap_labels = [lap1_time, lap2_time, lap3_time]

var total_laps = 3

func _ready():
	animation.play("camera")
	$GUI/main.show()
	$GUI/game.hide()
	$menu_music.play()

func _process(delta):
	show_debug_info()
	
	var player = car
	if player.tot_time:
		lap_counter.text = "LAPS " + str(1 + player.laps) + "/" + str(total_laps)
		tot_time.text = format(player.tot_time)
	else:
		lap_counter.text = ""
		tot_time.text = ""
	
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
	$game_music.play()


func format(duration):
	var ms = floor(duration%1000)/10
	var s = floor((duration/1000)%60)
	var m = floor((duration/(1000*60))%60)
	return "%02d:%02d:%02d" % [m, s, ms]


func _on_car_lap_completed(lap_counter, lap_time, total_time):
	var lap_label = lap_labels[lap_counter-1]
	lap_label.text = str(lap_counter) + ") " + format(lap_time)
	lap_label.show()
	
	if lap_counter == total_laps:
		print("END! ", total_time)
	else:		
		lap_completed.text = format(lap_time)
		lap_completed.show()
		yield(get_tree().create_timer(2.5), "timeout")
		lap_completed.hide()

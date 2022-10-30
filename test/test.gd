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
var race_end = false

func _ready():
	$GUI/main/change_name_btn/current_name.text = Globals.player_name
	animation.play("camera")
	$GUI/main.show()
	$GUI/game.hide()
	$GUI/enter_name.hide()
	$GUI/leaderboard.hide()
	$menu_music.play()

func _process(delta):
	show_debug_info()
	
	var player = car
	if player.tot_time and !race_end:
		lap_counter.text = "LAP " + str(1 + player.laps) + "/" + str(total_laps)
		tot_time.text = Globals.format_duration(player.tot_time)
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
	if Globals.player_name == "":
		$GUI/main.hide()
		$GUI/enter_name.show()
		yield($GUI/enter_name, "name_changed")
		$GUI/enter_name.hide()
	animation.stop()
	$menu_music.stop()
	$GUI/main.hide()
	$GUI/game.show()
	$Camera.current = false
	car.camera.current = true
	car.engine_sfx.play()
	$game_music.play()
	$track_start_finish/animation.play("race_begin")
	
func start_race():
	car.input_enabled = true

func _on_car_lap_completed(lap_counter, lap_time, total_time):
	var lap_label = lap_labels[lap_counter-1]
	lap_label.text = str(lap_counter) + ") " + Globals.format_duration(lap_time)
	lap_label.show()
	
	if lap_counter == total_laps:
		car.input_enabled = false
		race_end = true
		$GUI/leaderboard.submit_time(total_time)
		lap_completed.text = "FINAL TIME\n" + Globals.format_duration(total_time)
		lap_completed.show()
		yield(get_tree().create_timer(2.5), "timeout")
		lap_completed.hide()
		$GUI/game.hide()
		$GUI/leaderboard.show()
	else:
		lap_completed.text = "LAP " + str(lap_counter) + "\n" + Globals.format_duration(lap_time)
		lap_completed.show()
		yield(get_tree().create_timer(2.5), "timeout")
		lap_completed.hide()


func _on_back_button_pressed():
	get_tree().reload_current_scene()


func _on_change_name_btn_pressed():
	$GUI/main.hide()
	$GUI/enter_name.show()
	yield($GUI/enter_name, "name_changed")
	$GUI/main/change_name_btn/current_name.text = Globals.player_name
	$GUI/enter_name.hide()
	$GUI/main.show()


func _on_leaderboard_btn_pressed():
	$GUI/main.hide()
	$GUI/leaderboard.show()
	$GUI/leaderboard.update()

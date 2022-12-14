extends ColorRect

onready var loading = $loading
onready var message = $message
onready var indices = $table/indices
onready var players = $table/players
onready var scores = $table/scores

onready var record = false
onready var reload_on_back = false

func _ready():
	Globals.connect("leaderboard_ready", self, "_on_leaderboard_ready")
	message.hide()
	
func update():
	message.hide()
	Globals.fetch_leaderboard()
	if Globals.leaderboard:
		_on_leaderboard_ready(Globals.leaderboard)
		
func time_to_score(total_time):
	return max((99 * 60 * 1000) - total_time, 0)
	
func score_to_time(score):
	return max((99 * 60 * 1000) - score, 0)

func submit_time(total_time):
	Globals.score = time_to_score(total_time)
	
	var personal_record = Globals.score > Globals.max_score
	var world_record = Globals.leaderboard != null \
						&& (len(Globals.leaderboard) == 0 \
							|| (len(Globals.leaderboard) > 0 \
								&& Globals.score > int(Globals.leaderboard[0]["score"])))
	record = personal_record || world_record
	
	if record:
		Globals.leaderboard = null # Reset leaderboard to force update
		Globals.set_max_score(Globals.score)
	
	if world_record:
		message.text = "WORLD RECORD!  " + Globals.format_duration(total_time)
	elif personal_record:
		message.text = "PERSONAL RECORD!  " + Globals.format_duration(total_time)
	else:
		message.text = "FINAL TIME:  " + Globals.format_duration(total_time)
	
	message.show()
	Globals.submit_score_to_leaderboard()

func _on_leaderboard_ready(leaderboard):
	if len(leaderboard) == 0:
		loading.bbcode_text = "[center]NO DATA YET[/center]"
	else:
		remove_loading_sign()
		
	for i in range(min(10, len(leaderboard))):
		var user_name = leaderboard[i]["name"]
		var score = int(leaderboard[i]["score"])
		players.get_child(i).text = user_name.substr(0, 22)
		scores.get_child(i).text = Globals.format_duration(score_to_time(score))
		
		var font_color = Color.white
		if leaderboard[i]["me?"]:
			font_color = Color.red
			
		indices.get_child(i).add_color_override("font_color", font_color)
		players.get_child(i).add_color_override("font_color", font_color)
		scores.get_child(i).add_color_override("font_color", font_color)
			
func remove_loading_sign():
	loading.hide()


func _on_leaderboard_visibility_changed():
	if visible and record:
		$animation.play("new_record")
		$sfx.play()

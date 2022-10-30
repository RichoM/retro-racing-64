extends Node

const LEADERBOARD_ID = "635db2768f40bb11d8cf0253*dl2-5GtWWUeUu7ayP8r1QgF2WIFcLc-EufArRmZlgSCA"

const PC_ID_FILE_PATH = "user://uuid.retroracing64.bin"
const PLAYER_NAME_FILE_PATH = "user://player_name.retroracing64.bin"
const SCORE_FILE_PATH = "user://max_score.retroracing64.bin"

var pc_id
var player_name = ""
var max_score = 0

var score = 0
var leaderboard = null

var server_url = null

signal server_ready(url)
signal leaderboard_ready(leaderboard)

const uuid = preload("res://uuid.gd")

func _ready():
	read_pc_id()
	if pc_id == null:
		set_pc_id(uuid.v4())
	read_player_name()
	read_max_score()
	fetch_leaderboard()

func read_pc_id():
	var file = File.new()
	var error = file.open(PC_ID_FILE_PATH, File.READ)
	if error == OK:
		pc_id = file.get_as_text()
	file.close()
	
func set_pc_id(id):
	pc_id = id
	var file = File.new()
	file.open(PC_ID_FILE_PATH, File.WRITE)
	file.store_string(pc_id)
	file.close()
	
func read_player_name():
	var file = File.new()
	var error = file.open(PLAYER_NAME_FILE_PATH, File.READ)
	if error == OK:
		player_name = file.get_as_text()
	file.close()
	
func set_player_name(s):
	player_name = s
	var file = File.new()
	file.open(PLAYER_NAME_FILE_PATH, File.WRITE)
	file.store_string(player_name)
	file.close()

func read_max_score():
	var score_file = File.new()
	var error = score_file.open(SCORE_FILE_PATH, File.READ)
	if error == OK:
		max_score = score_file.get_64()
	score_file.close()

func set_max_score(score):
	max_score = score
	var score_file = File.new()
	score_file.open(SCORE_FILE_PATH, File.WRITE)
	score_file.store_64(max_score)
	score_file.close()


	
func fetch_server_url():
	if server_url != null:
		yield(get_tree(), "idle_frame")
	else:
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request("https://richom.github.io/sum.txt")
		var response = yield(http_request, "request_completed")
		http_request.queue_free()
		var response_code = response[1]
		var body = response[3]
		if response_code == 200: 
			var data = body.get_string_from_utf8()
			server_url = data.strip_edges().trim_suffix("/") + "/leaderboard/"
			print(server_url)
	emit_signal("server_ready", server_url)
	
func fetch_leaderboard():
	if server_url == null:
		fetch_server_url()
		yield(self, "server_ready")
		fetch_leaderboard()
	else:
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", self, "_on_leaderboard_ready")
		http_request.request(server_url + LEADERBOARD_ID)
		yield(http_request, "request_completed")
		http_request.queue_free()
	
func submit_score_to_leaderboard():
	if server_url == null: return # We better already have the server url!
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var player = pc_id + "@" + player_name.replace("*", "__ASTERISK__")
	var query = JSON.print({"player": player, "score": score})
	var headers = ["Content-Type: application/json"]
	var url = server_url + LEADERBOARD_ID
	
	http_request.connect("request_completed", self, "_on_leaderboard_ready")
	http_request.request(url, headers, true, HTTPClient.METHOD_POST, query)
	yield(http_request, "request_completed")
	http_request.queue_free()


func _on_leaderboard_ready(result, response_code, headers, body):
	if response_code != 200: return
	
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error != OK: return
	
	leaderboard = json.result["dreamlo"]["leaderboard"]
	if leaderboard == null: # The leaderboard is empty
		leaderboard = []
	else:
		leaderboard = leaderboard["entry"]
		
		# HACK(Richo): It seems if only one score is submitted we don't get an array
		if typeof(leaderboard) != TYPE_ARRAY:
			leaderboard = [leaderboard]
			
		for i in range(len(leaderboard)):
			var full_name = leaderboard[i]["name"]
			var name_parts = full_name.split("@", true, 1)
			var id = ""
			var name = ""
			if len(name_parts) == 1:
				name = name_parts[0]
			else:
				id = name_parts[0]
				name = name_parts[1]
			name = name.replace("__ASTERISK__", "*")
				
			var score = leaderboard[i]["score"]
			var is_me = pc_id == id and player_name == name
			leaderboard[i] = {"name": name, "score": score, "me?": is_me}
	
	print(leaderboard)
	emit_signal("leaderboard_ready", leaderboard)



func format_duration(duration):
	var ms = floor(duration%1000)/10
	var s = floor((duration/1000)%60)
	var m = floor((duration/(1000*60))%60)
	return "%02d:%02d:%02d" % [m, s, ms]

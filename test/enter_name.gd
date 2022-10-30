extends Control

export var player_name_path : NodePath
onready var player_name : LineEdit = get_node(player_name_path)

signal name_changed()

func _ready():
	if Globals.player_name != "":
		player_name.placeholder_text = Globals.player_name
	else:
		randomize()
		player_name.placeholder_text = "Anon" + str(randi() % 9000 + 1000)

func _on_player_name_text_entered(new_text):
	accept()

func _on_accept_btn_pressed():
	accept()
	
func accept():
	var name = player_name.text.strip_edges()
	if name != "":
		Globals.set_player_name(name)
	else:
		Globals.set_player_name(player_name.placeholder_text)
	
	emit_signal("name_changed")

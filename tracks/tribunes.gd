extends MeshInstance

onready var rng = RandomNumberGenerator.new()

var initial_positions = []
var time = 0

func _ready():
	rng.randomize()
	
	# HACK(Richo): In my mobile phone the framerate drops significantly when having
	# the people in the tribunes. I don't have much time to optimize this before the
	# deadline so I decided to simply remove them if I detect the touchscreen hint.
	if OS.has_touchscreen_ui_hint():
		for c in get_children():
			remove_child(c)
	else:
		for c in get_children():
			initial_positions.append(c.translation.y)
	
func _process(delta):
	time += delta
	if time < 0.2: return
	time = 0
	for idx in get_child_count():
		var initial_y = initial_positions[idx]
		var child : Spatial = get_child(idx)
		if rng.randf() < 0.5:
			child.translation.y = initial_y + 30
		else:
			child.translation.y = initial_y + 0

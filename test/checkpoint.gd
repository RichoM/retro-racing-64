extends Area

export var car_path : NodePath
onready var car = get_node(car_path) as Car

export var number = 0
onready var total = get_parent().get_child_count()

func _on_checkpoint_body_entered(body):
	if car: car.entered_checkpoint(number, total)

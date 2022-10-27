extends AnimatedSprite

func _ready():
	visible = OS.has_touchscreen_ui_hint()

func _on_button_pressed():
	frame = 1

func _on_button_released():
	frame = 0

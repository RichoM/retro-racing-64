extends AnimatedSprite

onready var button : TouchScreenButton = $button

func _process(delta):
	if !OS.has_touchscreen_ui_hint():
		frame = 1 if Input.is_action_pressed(button.action) else 0

func _on_button_pressed():
	frame = 1

func _on_button_released():
	frame = 0

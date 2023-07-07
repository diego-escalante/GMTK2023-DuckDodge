extends Node

func _unhandled_key_input(event):
	if event.is_pressed() and (event as InputEventKey).keycode == KEY_SPACE:
		RenderingServer.set_default_clear_color(Color(randf(), randf(), randf()))

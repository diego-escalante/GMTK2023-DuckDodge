extends Label

@export var on_duration := 0.5
@export var off_duration := 0.25

var _str: String

func _ready():
	_str = text
	_toggle(true)
	
func _toggle(is_vis: bool):
	text = _str if is_vis else " "
	await get_tree().create_timer(on_duration if is_vis else off_duration).timeout
	_toggle(!is_vis)

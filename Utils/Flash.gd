extends Label

@export var on_duration := 0.5
@export var off_duration := 0.25

var str: String

func _ready():
	str = text
	_toggle(true)
	
func _toggle(is_visible: bool):
	text = str if is_visible else " "
	await get_tree().create_timer(on_duration if is_visible else off_duration).timeout
	_toggle(!is_visible)

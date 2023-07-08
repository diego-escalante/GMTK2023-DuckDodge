extends PanelContainer

@onready var round_label := $HBoxContainer/Number

func _ready() -> void:
	Events.round_start.connect(_show)
	Events.duck_fly_in.connect(func(): visible = false)
		
func _show(round_number: int, _a, _b) -> void:
	round_label.text = str(round_number)
	visible = true
	

extends PanelContainer

var shots := 0

@onready var shots_label := $MarginContainer/HBoxContainer/Labels/ShotsNumber as Label

func _ready() -> void:
	Events.shot.connect(_shot)
	Events.duck_fly_in.connect(_reset)
	
func _shot(_a) -> void:
	shots = max(shots - 1, 0)
	_update_text()

func _reset() -> void:
	shots = 3
	_update_text()
	
func _update_text() -> void:
	var s := ""
	for i in shots:
		s += "X "
	for i in 3 - shots:
		s += "  "
	s = s.substr(0, s.length() - 1)
	shots_label.text = s

extends PanelContainer

var _duck_required := 0
var _total_ducks := 0
var _current_duck := 0
var _ducks_saved := 0

@onready var saved_label := $MarginContainer/HBoxContainer/Numbers/SavedNumber as Label
@onready var current_label := $MarginContainer/HBoxContainer/Numbers/CurrentNumber as Label

func _ready() -> void:
	Events.round_start.connect(_new_round)
	Events.duck_fly_in.connect(_new_duck)
	Events.duck_fly_out.connect(_duck_saved)
	
	
func _duck_saved() -> void:
	_ducks_saved += 1
	_update_text()

func _new_duck() -> void:
	_current_duck += 1
	_update_text()

func _new_round(_round_number: int, ducks_required: int, total_ducks: int) -> void:
	_ducks_saved = 0
	_current_duck = 0
	_total_ducks = total_ducks
	_duck_required = ducks_required
	_update_text()


func _update_text() -> void:
	saved_label.text = "%s/%s" % [_str0(_ducks_saved), _str0(_duck_required)]
	current_label.text = "%s/%s" % [_str0(_current_duck), _str0(_total_ducks)] 


func _str0(number: int) -> String:
	return str(number) if number > 9 else " " + str(number)

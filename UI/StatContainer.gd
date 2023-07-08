extends PanelContainer

@onready var round_number_label := $MarginContainer/HBoxContainer/Numbers/RoundNumber as Label
@onready var score_number_label := $MarginContainer/HBoxContainer/Numbers/ScoreNumber as Label

func _ready() -> void:
	Events.round_start.connect(func(round_number, _a, _b): round_number_label.text = (str(round_number) if round_number > 9 else " " + str(round_number)))
	Events.score_updated.connect(func(current_score): score_number_label.text = (str(current_score) if current_score > 9 else " " + str(current_score)))

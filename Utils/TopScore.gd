extends Node

var top_score := 0
var furthest_round := 0

func _ready() -> void:
	Events.score_updated.connect(func(current_score): top_score = current_score if current_score > top_score else top_score)
	Events.round_start.connect(func(round_number, _a, _b): furthest_round = round_number if round_number > furthest_round else furthest_round)

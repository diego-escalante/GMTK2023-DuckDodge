extends Label

func _ready() -> void:
	text = """Top Score: %s
	Furthest Round: %s""" % [str(TopScore.top_score), str(TopScore.furthest_round)]

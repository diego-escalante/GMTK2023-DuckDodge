extends PanelContainer

@onready var message := $Message as Label

func _ready() -> void:
	Events.show_message.connect(_show)
	Events.hide_message.connect(_hide)
	
	
func _show(msg: String) -> void:
	message.text = msg
	visible = true
	
func _hide() -> void:
	visible = false

extends CanvasLayer

@onready var black_screen := $BlackScreen as ColorRect
@onready var duck_flash := $DuckFlash as ColorRect

func _ready() -> void:
	Events.shot.connect(_flash)


func _flash(_a) -> void:
	black_screen.visible = true
#	await get_tree().create_timer(0.075).timeout
	await get_tree().physics_frame
	await get_tree().physics_frame
#	var duck = get_tree().get_first_node_in_group("ducks") as Duck
#	if duck != null:
#		duck_flash.global_position = duck.global_position - Vector2.ONE * 16
#		duck_flash.visible = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	black_screen.visible = false
#	duck_flash.visible = false

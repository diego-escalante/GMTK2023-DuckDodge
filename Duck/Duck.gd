extends CharacterBody2D
class_name Duck

@export var vel := Vector2.RIGHT
@export var speed := 100.0

func _ready():
	velocity = vel * speed


func _physics_process(_delta):
	velocity = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized() * speed
	move_and_slide()

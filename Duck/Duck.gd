extends CharacterBody2D
class_name Duck

enum State {FLYING_IN, FLYING, FLYING_OUT}

@export var vel := Vector2.RIGHT
@export var speed := 100.0

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D

var state := State.FLYING_IN

func _ready():
	Events.duck_fly_out.connect(_fly_out)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_flew_out)


func _physics_process(_delta):
	
	var input := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	
	if state == State.FLYING_IN or state == State.FLYING_OUT:
		input.y = -1
	
	if state == State.FLYING_IN and position.y < 128:
		Events.duck_flew_in.emit()
		set_collision_mask_value(4, true)
		state = State.FLYING
			
	
	velocity = input.normalized() * speed
	
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0
	
	if velocity.y < 0 && velocity.x != 0:
		animated_sprite.set_animation("diagonal")
	elif velocity.y < 0 && velocity.x == 0:
		animated_sprite.set_animation("up")
	elif velocity.x != 0 || velocity.y > 0:
		animated_sprite.set_animation("side")

	move_and_slide()


func _fly_out() -> void:
	state = State.FLYING_OUT
	set_collision_mask_value(3, false)


func _flew_out() -> void:
	Events.duck_flew_out.emit()
	queue_free()

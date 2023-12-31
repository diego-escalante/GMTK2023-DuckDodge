extends CharacterBody2D
class_name Duck

enum State {FLYING_IN, FLYING, FLYING_OUT, SHOT, FALLING}

@export var vel := Vector2.RIGHT
@export var speed := 112.0

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var quack_timer := $QuackTimer as Timer
@onready var flap_timer := $FlapTimer as Timer

var state := State.FLYING_IN
var last_flap_low := false

func _ready():
	RenderingServer.set_default_clear_color(Color("4696ff"))
	Events.shot.connect(_shot)
	Events.duck_fly_out.connect(_fly_out)
	quack_timer.timeout.connect(func(): AudioPlayer.play_sound(AudioPlayer.QUACK))
	flap_timer.timeout.connect(_flap)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_flew_out)
	
	
func _flap():
	last_flap_low = !last_flap_low
	AudioPlayer.play_sound(AudioPlayer.FLAP_HIGH if last_flap_low else AudioPlayer.FLAP_LOW)

func _physics_process(_delta):
	if state == State.SHOT:
		return
		
	if state == State.FALLING:
		move_and_slide()
		if position.y > 160:
			Events.duck_fell.emit()
			AudioPlayer.stop_sound(AudioPlayer.FALL)
			AudioPlayer.play_sound(AudioPlayer.THUD)
			queue_free()
		return
	
	
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
	Events.show_message.emit("FLY AWAY")
	RenderingServer.set_default_clear_color(Color("bd82a0"))


func _flew_out() -> void:
	Events.duck_flew_out.emit()
	queue_free()


func _shot(hit: bool) -> void:
	if not hit:
		return
	state = State.SHOT
	quack_timer.stop()
	flap_timer.stop()
	Events.shot.disconnect(_shot)
	Events.duck_fly_out.disconnect(_fly_out)
	animated_sprite.set_animation("shot")
	await get_tree().create_timer(0.4).timeout
	state = State.FALLING
	AudioPlayer.play_sound(AudioPlayer.FALL)
	animated_sprite.set_animation("fall")
	set_collision_mask(0)
	velocity = Vector2.DOWN * speed

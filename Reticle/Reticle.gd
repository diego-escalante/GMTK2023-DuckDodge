extends CharacterBody2D


# Reticle moves and tries to aim and shoot ducks. 

# Basic reticle movement: Move in a straight light to the duck.
# Advanced reticle movement: Predict where the duck will be and move there.
# Random reticle movement to break up predictable movement:
#  * Stop moving for a moment.
#  * Move to a random location.
#  * Vary the movement speed a bit?

# Maybe there is a way to blend between basic and advanced movement?

# AI can't be perfect. Some handicaps that it can be given and slowly relieve over rounds include:
#  * Movement speed, progressively getting faster.
#  * Target position can be in a random circle's area, progressively getting smaller (more accurate).
#  * Shooting can be inaccurate, randomly shooting when close but not necessarily on target, progressively only shooting when the hit is guaranteed.

# Other attributes to the reticle:
#  * Shoot cooldown: How quickly can the reticle attempt to shoot after a previous attempt? CD decreases over rounds. 
#  * accuracy 0-1: Low accuracy means shooting outside of the duck's area and not shooting inside the duck's area when it is able to make an attempt. Think about it as a roll to see if it happens. 

@export var speed := 112.0						# The speed of the target.
@export var set_target_interval := 0.5			# How often should a new target be chosen?
@export var target_radius := 128				# How far can the target position be from the optimal desired position?
@export var shoot_radius := 128					# How close to the duck before attempting to shoot? (Not guaranteed to be ON the duck)
@export var shoot_accuracy := 0.75				# How likely is a shot to land? How likely is there a missed chance for a shot?
@export var shoot_interval := 0.5				# How often should we attempt to shoot?

@export var no_new_target_position_weight := 1
@export var random_target_position_weight := 2
@export var current_target_position_weight := 2
@export var predicted_target_position_weight := 2


@onready var set_target_timer: TimerWithRandomRange = $SetTargetTimer
@onready var shoot_timer: Timer = $ShootTimer

var _duck: Duck
var _target_pos: Vector2
var _current_speed := speed
var target_hit_distance := 24			# How close to the duck in order to hit it with a shot?

enum TargetLogic {NONE, RANDOM, CURRENT, PREDICTED}

func _choose_target_logic() -> TargetLogic:
	var total := no_new_target_position_weight + random_target_position_weight + current_target_position_weight + predicted_target_position_weight
	var val := randf_range(0, total)
	
	if val < no_new_target_position_weight:
		return TargetLogic.NONE
	
	val -= no_new_target_position_weight
	if val < random_target_position_weight:
		return TargetLogic.RANDOM
		
	val -= random_target_position_weight
	if val < current_target_position_weight:
		return TargetLogic.CURRENT
		
	return TargetLogic.PREDICTED

func _ready() -> void:
	_target_pos = position
	
	Events.round_start.connect(_set_config)
	Events.duck_flew_in.connect(_start)
	Events.duck_fly_out.connect(_stop)
	
	shoot_timer.timeout.connect(_shoot)
	set_target_timer.timeout.connect(_target_timer_timeout)
	
	_stop()
	
	
func _set_config(round_num: int, _a, _b) -> void:
	speed = remap(round_num, -3, 8, 128, 168)
	set_target_interval = max(remap(round_num, -3, 8, 1, 0.02), 0.02)
	target_radius = max(remap(round_num, -3, 8, 64, 0), 0)
	shoot_accuracy = min(remap(round_num, -3, 8, 0.4, 0.7), 1)
	shoot_radius = max(remap(round_num, -3, 8, 64, 24), 0)
	shoot_interval = max(remap(round_num, -3, 8, 1.5, 0.1), 0.05)
	
	no_new_target_position_weight = max(remap(round_num, -3, 8, 2, 0.5), 0)
	random_target_position_weight = max(remap(round_num, -3, 8, 3, 1), 0)
	current_target_position_weight = max(remap(round_num, -3, 8, 2, 1), 0)
	predicted_target_position_weight = remap(round_num, -3, 8, 1, 2)


func _start() -> void:
	_duck = get_tree().get_first_node_in_group("ducks") as Duck
	await get_tree().create_timer(0.25).timeout
	position = Vector2(128, 160)
	visible = true
	_set_target_pos()
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()
	set_target_timer.set_new_wait_time(set_target_interval, set_target_interval * 0.1)
	set_target_timer.start()

func _stop() -> void:
	_duck = null
	visible = false
	shoot_timer.stop()
	set_target_timer.stop()
	velocity = Vector2.ZERO
	_target_pos = position


func _physics_process(_delta) -> void:
	if position.distance_to(_target_pos) > 5:
		velocity = position.direction_to(_target_pos) * _current_speed
		move_and_slide()
	else:
		position = _target_pos


func _target_timer_timeout() -> void:
	_set_target_pos()


func _shoot() -> void:
	var within_shoot_radius := position.distance_to(_duck.position) < shoot_radius
	var do_a_shoot := (within_shoot_radius and randf() < shoot_accuracy) or (!within_shoot_radius and randf() > shoot_accuracy)
	
	if do_a_shoot:
		var hit = position.distance_to(_duck.position) < target_hit_distance
		AudioPlayer.play_sound(AudioPlayer.ZAP)
		if hit:
			_stop()
		Events.shot.emit(hit)


func _set_target_pos() -> void:
	_current_speed = speed + randf_range(-speed * 0.2, speed * 0.2)
	
	# Choose a targeting strategy
	var targeting_logic := _choose_target_logic()
	
	# Get ideal target position based on strategy.
	match targeting_logic:
		TargetLogic.NONE:
			_target_pos = position
		TargetLogic.RANDOM:
			_target_pos = Vector2(randi_range(16, 240), randi_range(16, 128))
		TargetLogic.CURRENT:
			_target_pos = _duck.position
		TargetLogic.PREDICTED:
			if _duck.velocity == Vector2.ZERO:
				_target_pos = _duck.position
			else:
				var interception_result := _interception_direction(_duck.position, position, _duck.velocity, _current_speed)
				if (interception_result[0]):
					_target_pos = interception_result[1]
				else:
					_target_pos = _duck.position
					
	# Move the target to a random location within target_radius
	_target_pos += randv_circle(0, target_radius)
	
	# Target position could be outside of the play area. Clamp it.
	_target_pos = Vector2(clamp(_target_pos.x, 16, 240), clamp(_target_pos.y, 16, 128))
	
# https://www.reddit.com/r/godot/comments/vjge0n/could_anyone_share_some_code_for_finding_a/idjqb13/
func randv_circle(min_radius := 1.0, max_radius := 1.0) -> Vector2:
	var r2_max := max_radius * max_radius
	var r2_min := min_radius * min_radius
	var r := sqrt(randf() * (r2_max - r2_min) + r2_min)
	var t := randf() * TAU
	return Vector2(r, 0).rotated(t)


# Based on jean-gobert de coster's video on predictive aim: https://youtu.be/2zVwug_agr0
# Returns an array with a bool indicating if a valid solution was found, and if so, the direction it found.
func _interception_direction(a: Vector2, b: Vector2, vA: Vector2, sB: float) -> Array:
	var aToB := b - a
	var dC := aToB.length()
	var alpha := aToB.angle_to(vA)
	var sA := vA.length()
	var r := sA / sB
	
	var quad_result := _solve_quadratic(1-r*r, 2 * r * dC * cos(alpha), -(dC * dC))
	if quad_result[0] == 0:
		return [false, Vector2.ZERO]
	var dA: float = max(quad_result[1], quad_result[2])
	var t := dA / sB
	var c = a + vA * t
	return [true, c]


# Returns an array with the number of valid roots, and the quadratic roots.
func _solve_quadratic(a: float, b: float, c: float) -> Array:
	var discriminant := b * b - 4 * a * c
	if discriminant < 0:
		return [0, INF, -INF]
	return [2 if discriminant > 0 else 1, (-b + sqrt(discriminant)) / (2 * a), (-b - sqrt(discriminant)) / (2 * a)]

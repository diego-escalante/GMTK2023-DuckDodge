extends CharacterBody2D


# Reticle moves and tries to aim and shoot ducks. 

# Basic reticle movement: Move in a straight light to the duck.
# Advanced reticle movement: Predict where the duck will be and move there.
# Extra Advanced reticle movement: Quickly move into position to where the duck will be.
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

@export var speed := 20.0

@onready var set_target_timer: TimerWithRandomRange = $SetTargetTimer

var _duck: Duck
var _target_pos: Vector2

func _ready() -> void:
	set_target_timer.timeout.connect(_target_timer_timeout)
	_get_duck()
	_set_target_pos()

func _physics_process(_delta) -> void:
	if position.distance_to(_target_pos) > 5:
		move_and_slide()


func _target_timer_timeout() -> void:
	_set_target_pos()



func _get_duck() -> void:
	_duck = get_tree().get_first_node_in_group("ducks") as Duck


func _set_target_pos() -> void:
	if _duck == null:
		_get_duck()
		if _duck == null:
			_target_pos = position
			velocity = Vector2.ZERO
			return
		
	if _duck.velocity == Vector2.ZERO:
		_target_pos = _duck.position
		velocity = position.direction_to(_target_pos) * speed
		return 
		
	var interception_result := _interception_direction(_duck.position, position, _duck.velocity, speed)
	if (interception_result[0]):
		_target_pos = interception_result[1]
	else:
		_target_pos = _duck.position
	
	velocity = position.direction_to(_target_pos) * speed


func _basic_follow() -> void:
	velocity = position.direction_to(_target_pos) * speed
	move_and_slide()


# Based on jean-gobert de coster's video on predictive aim: https://youtu.be/2zVwug_agr0
func _predict_follow() -> void:
	var interception_result := _interception_direction(_target_pos, position, _duck.velocity, speed)
	if interception_result[0]:
		velocity = interception_result[1] * speed
		move_and_slide()
	else:
		# Fall back to basic follow if it is impossible to intercept.
		_basic_follow()


# Returns an array with the number of valid roots, and the quadratic roots.
func _solve_quadratic(a: float, b: float, c: float) -> Array:
	var discriminant := b * b - 4 * a * c
	if discriminant < 0:
		return [0, INF, -INF]
	return [2 if discriminant > 0 else 1, (-b + sqrt(discriminant)) / (2 * a), (-b - sqrt(discriminant)) / (2 * a)]


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

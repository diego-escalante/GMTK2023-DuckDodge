extends Timer
class_name TimerWithRandomRange

@export var delta_wait_time := 0.5
var _original_wait_time: float

func set_new_wait_time(new_wait_time: float, new_delta_wait_time: float):
	_original_wait_time = new_wait_time
	delta_wait_time = new_delta_wait_time
	_set_random_wait_time()

func _ready():
	_original_wait_time = wait_time
	_set_random_wait_time()
	timeout.connect(_set_random_wait_time)
	

func _set_random_wait_time() -> void:
	wait_time = _original_wait_time + randf_range(-delta_wait_time, delta_wait_time)

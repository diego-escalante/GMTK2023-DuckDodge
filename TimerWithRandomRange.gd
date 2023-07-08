extends Timer
class_name TimerWithRandomRange

@export var minimumWaitTime := 0.0
@export var maximumWaitTime := 1.0

func _ready():
	wait_time = randf_range(minimumWaitTime, maximumWaitTime)
	timeout.connect(func(): wait_time = randf_range(minimumWaitTime, maximumWaitTime))

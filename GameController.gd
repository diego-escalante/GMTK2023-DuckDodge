extends Node

enum State {ROUND_START, DUCK_FLY_IN, DUCK_FLYING, DUCK_SHOT, DUCK_FLY_OUT, ROUND_END}

@export var round_start_duration := 1.0
@export var duck_flying_time := 5.0
@export var pause_duration := 1.0

var current_round := 0
var current_duck := 0
var ducks_required := 4
var ducks_saved := 0
var score := 0
var total_ducks_in_round := 10
var shots := 3
var state: State = State.ROUND_START

var check_val := 0

var duck_scene := preload("res://Duck/Duck.tscn")

func _ready() -> void:
	score = 0
	Events.score_updated.emit(score)
	Events.shot.connect(_detect_shot)
	Events.duck_fell.connect(_finish_current_flight)
	_start_round()


func _process(_delta) -> void:
	if Input.is_action_just_pressed("esc"):
		_switch_to_title_screen()


func _start_round() -> void:
	current_round += 1
	ducks_saved = 0
	current_duck = 0
	state = State.ROUND_START
	Events.hide_message.emit()
	RenderingServer.set_default_clear_color(Color("4696ff"))
	Events.round_start.emit(current_round, ducks_required, total_ducks_in_round)
	await get_tree().create_timer(round_start_duration).timeout
	_fly_in_duck()


func _fly_in_duck() -> void:
	shots = 3
	current_duck += 1
	state = State.DUCK_FLY_IN
	_spawn_duck()
	Events.hide_message.emit()
	Events.duck_fly_in.emit()
	await Events.duck_flew_in
	_flying_duck()


func _flying_duck() -> void:
	state = State.DUCK_FLYING
	Events.duck_flying.emit()
	_await_duck_flying_time_with_cancel()
	
	
func _await_duck_flying_time_with_cancel() -> void:
	var current_check_val = check_val
	await get_tree().create_timer(duck_flying_time).timeout
	if (current_check_val == check_val):
		_fly_out_duck()


func _fly_out_duck() -> void:
	if state != State.DUCK_FLYING:
		return
	ducks_saved += 1
	score += 1
	state = State.DUCK_FLY_OUT
	Events.score_updated.emit(score)
	Events.duck_fly_out.emit()
	await Events.duck_flew_out
	_finish_current_flight()


func _finish_current_flight() -> void:
	await get_tree().create_timer(pause_duration).timeout
	if current_duck == total_ducks_in_round:
		if ducks_saved >= ducks_required:
			_start_round()
		else:
			Events.show_message.emit("GAME OVER")
			await get_tree().create_timer(3).timeout
			_switch_to_title_screen()
	else:
		_fly_in_duck()


func _switch_to_title_screen() -> void:
	get_tree().change_scene_to_file("res://UI/TitleScreen.tscn")


func _spawn_duck() -> void:
	var new_duck := duck_scene.instantiate()
	owner.add_child(new_duck)
	new_duck.position = Vector2(randi_range(48, 224), 160)


func _detect_shot(hit: bool) -> void:
	if hit:
		check_val += 1
		return
	shots -= 1
	if shots == 0:
		check_val += 1
		_fly_out_duck()

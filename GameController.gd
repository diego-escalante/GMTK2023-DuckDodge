extends Node

enum State {ROUND_START, DUCK_FLY_IN, DUCK_FLYING, DUCK_SHOT, DUCK_FLY_OUT, ROUND_END}

@export var round_start_duration := 1.0
@export var duck_flying_time := 3.0
@export var pause_duration := 1.0

var current_round := 0
var current_duck := 0
var ducks_required := 4
var ducks_saved := 0
var score := 0
var total_ducks_in_round := 10
var state: State = State.ROUND_START

var duck_scene := preload("res://Duck/Duck.tscn")

func _ready() -> void:
	score = 0
	Events.score_updated.emit(score)
	_start_round()


func _process(_delta) -> void:
	if Input.is_action_just_pressed("esc"):
		_switch_to_title_screen()


func _start_round() -> void:
	current_round += 1
	ducks_saved = 0
	current_duck = 0
	state = State.ROUND_START
	Events.round_start.emit(current_round, ducks_required, total_ducks_in_round)
	await get_tree().create_timer(round_start_duration).timeout
	_fly_in_duck()


func _fly_in_duck() -> void:
	current_duck += 1
	state = State.DUCK_FLY_IN
	_spawn_duck()
	Events.duck_fly_in.emit()
	await Events.duck_flew_in
	_flying_duck()


func _flying_duck() -> void:
	state = State.DUCK_FLYING
	Events.duck_flying.emit()
	await get_tree().create_timer(duck_flying_time).timeout
	_fly_out_duck()


func _fly_out_duck() -> void:
	ducks_saved += 1
	score += 1
	state = State.DUCK_FLY_OUT
	Events.score_updated.emit(score)
	Events.duck_fly_out.emit()
	await Events.duck_flew_out
	await get_tree().create_timer(pause_duration).timeout
	if current_duck == total_ducks_in_round:
		_start_round()
	else:
		_fly_in_duck()


func _switch_to_title_screen() -> void:
	get_tree().change_scene_to_file("res://UI/TitleScreen.tscn")


func _spawn_duck() -> void:
	var new_duck := duck_scene.instantiate()
	owner.add_child(new_duck)
	new_duck.position = Vector2(randi_range(48, 224), 160)

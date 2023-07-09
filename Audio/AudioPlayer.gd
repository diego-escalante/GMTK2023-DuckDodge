extends Node

@export var number_of_players := 8
const BARK = preload("res://Audio/SFX/bark.wav")
const FALL = preload("res://Audio/SFX/fall.wav")
const FLAP_HIGH = preload("res://Audio/SFX/flap_high.wav")
const FLAP_LOW = preload("res://Audio/SFX/flap_low3.wav")
const ZAP = preload("res://Audio/SFX/full_zap2.wav")
const QUACK = preload("res://Audio/SFX/quack.wav")
const THUD = preload("res://Audio/SFX/thud.wav")


var current_player_index := number_of_players-1
@onready var audio_players := $AudioPlayers


func _ready():
	for i in number_of_players:
		var audio_player := AudioStreamPlayer.new()
		audio_player.bus = "Sound"
		audio_players.add_child(audio_player)
		

func stop_sound(sound: AudioStream) -> void:
	for i in number_of_players:
		var player: AudioStreamPlayer = audio_players.get_child(i)
		if player.is_playing() and player.stream == sound:
			player.stop()


func play_sound(sound: AudioStream) -> void:	
	var audio_player := get_next_player()
	audio_player.stream = sound
	audio_player.play()

# Attempts to find the next available player via round robin, skipping players
# that are still active. If all players are active, 
func get_next_player() -> AudioStreamPlayer:
	var iterations := 0
	while true:
		iterations += 1
		current_player_index = (current_player_index + 1) % number_of_players
		
		var audio_player: AudioStreamPlayer = audio_players.get_child(current_player_index)
		if not audio_player.is_playing():
			return audio_player
		elif iterations == number_of_players:
			# We cycled through all players; all unavailable. So take the next one anyway.
			printerr("Could not find an available AudioStreamPlayer. Taking an in-progress one.")
			current_player_index = (current_player_index + 1) % number_of_players
			return audio_players.get_child(current_player_index) as AudioStreamPlayer
			
	# Impossible to get here; this just makes the interpreter happy.
	return null

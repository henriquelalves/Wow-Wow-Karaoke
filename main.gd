extends Control

const WINDOW_FORWARD := 1.0

@export var karaoke_song: KaraokeSong
@onready var lyric_line_1 = $VBoxContainer/LyricLine1
@onready var lyric_line_2 = $VBoxContainer/LyricLine2
@onready var song_time := 0.0
@onready var min_token := 0


func _ready():
	var durations :Array[float] = []
	for i in range(karaoke_song.tokens_timestamps[0].size()-1):
		durations.append(karaoke_song.tokens_timestamps[0][i+1] - karaoke_song.tokens_timestamps[0][i])
	
	var tween := create_tween()
	tween.tween_property(
		$Background, "scale", Vector2.ONE * 2.0, $AudioStreamPlayer.stream.get_length()
	)


func _process(delta: float) -> void:
	song_time += delta
	
	if min_token >= karaoke_song.tokens_timestamps.size():
		return
	
	if karaoke_song.tokens_timestamps[min_token][0] >= song_time + WINDOW_FORWARD:
		return
	
	while (
		min_token < karaoke_song.tokens_timestamps.size() and 
		karaoke_song.tokens_timestamps[min_token][0] < song_time + WINDOW_FORWARD):
		
		if lyric_line_1.is_playing() and lyric_line_2.is_playing():
			return
		
		if karaoke_song.tokens_timestamps[min_token][0] < 0.0:
			return
		
		if not lyric_line_1.is_playing():
			lyric_line_1.set_lyric_line(karaoke_song.tokens[min_token], karaoke_song.tokens_timestamps[min_token], song_time)
			min_token += 1
		elif not lyric_line_2.is_playing():
			lyric_line_2.set_lyric_line(karaoke_song.tokens[min_token], karaoke_song.tokens_timestamps[min_token], song_time)
			min_token += 1

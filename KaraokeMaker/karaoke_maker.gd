extends Control

const LineToken = preload("line_token.tscn")

@export var karaoke_song : KaraokeSong

@onready var hslider : HSlider = %HSlider
@onready var audio : AudioStreamPlayer = %AudioStreamPlayer
@onready var line_container : HBoxContainer = %LineContainer
@onready var token_select_rect : Panel = %TokenSelectRect
@onready var current_word_rect : Panel = %CurrentWordRect

@onready var current_line := 0
@onready var selected_token := 0

var tokens : Array[PackedStringArray] = []
var tokens_timestamps : Array[PackedFloat32Array]= []


func _ready() -> void:
	hslider.drag_started.connect(func():
		audio.seek(float(hslider.value)*audio.stream.get_length())
		)
	audio.play()

	if karaoke_song.tokens.is_empty():
		tokens = Utils.parse_lyrics_to_tokens(karaoke_song.lyrics)
		for tokens_line in tokens:
			var array : PackedFloat32Array = []
			array.resize(tokens_line.size() + 1)
			array.fill(-1.0)
			tokens_timestamps.append(array)
	else:
		_sanity_check()
		tokens = karaoke_song.tokens
		tokens_timestamps = karaoke_song.tokens_timestamps

	set_line(0)
	select_token(0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("previous_line"):
		set_line(current_line - 1)
	elif event.is_action_pressed("next_line"):
		set_line(current_line + 1)
	elif event.is_action_pressed("previous_token"):
		select_token(selected_token - 1)
	elif event.is_action_pressed("next_token"):
		select_token(selected_token + 1)
	elif event.is_action_pressed("update_token"):
		update_selected_token_time()
	elif event.is_action_pressed("save"):
		save()


func set_line(line_idx: int) -> void:
	line_idx = clamp(line_idx, 0, tokens.size()-1)

	for child in line_container.get_children():
		child.free()

	var line_tokens = tokens[line_idx]
	for token in line_tokens:
		var token_scene = LineToken.instantiate()
		line_container.add_child(token_scene)
		token_scene.set_token_label(token)
	var token_scene = LineToken.instantiate()
	line_container.add_child(token_scene)
	token_scene.set_token_label("")
	current_line = line_idx

	for i in line_tokens.size():
		line_container.get_child(i).set_timestamp_label(tokens_timestamps[current_line][i])

	select_token(0)
	save()


func select_token(token: int) -> void:
	token = clamp(token, 0, line_container.get_child_count()-1)
	await get_tree().process_frame
	var rect : Rect2 = line_container.get_child(token).get_global_rect()
	token_select_rect.global_position = rect.position
	token_select_rect.size = rect.size
	selected_token = token


func update_selected_token_time() -> void:
	var line_token : LineToken = line_container.get_child(selected_token)
	var audio_pos := audio.get_playback_position()
	line_token.set_timestamp_label(audio_pos)
	tokens_timestamps[current_line][selected_token] = audio_pos

	if selected_token == line_container.get_child_count()-1:
#		set_line(current_line + 1)
		pass
	else:
		select_token(selected_token + 1)


func save() -> void:
	karaoke_song.tokens.assign(tokens)
	karaoke_song.tokens_timestamps = tokens_timestamps
	ResourceSaver.save(karaoke_song)


func _sanity_check() -> void:
	var res_tokens := Utils.parse_lyrics_to_tokens(karaoke_song.lyrics)

	while res_tokens.size() != karaoke_song.tokens.size():
		if karaoke_song.tokens.size() < res_tokens.size():
			var array : PackedFloat32Array = []
			var line := res_tokens[karaoke_song.tokens.size()]
			array.resize(line.size())
			array.fill(-1.0)
			karaoke_song.tokens.append(line.duplicate())
			karaoke_song.tokens_timestamps.append(array)
		else:
			karaoke_song.tokens.pop_back()
	
	karaoke_song.tokens = res_tokens
	for i in karaoke_song.tokens.size():
		while karaoke_song.tokens_timestamps[i].size() != res_tokens[i].size() + 1:
			if karaoke_song.tokens_timestamps[i].size() < res_tokens[i].size() + 1:
				karaoke_song.tokens_timestamps[i].append(-1.0)
			else:
				karaoke_song.tokens_timestamps[i].remove_at(karaoke_song.tokens_timestamps[i].size()-1)


func _process(delta: float) -> void:
	var playback_pos := audio.get_playback_position()
	hslider.value = playback_pos / audio.stream.get_length()

	var i := tokens_timestamps[current_line].size() - 1
	while i > -1:
		if playback_pos < tokens_timestamps[current_line][i]:
			i -= 1
		else:
			break
	current_word_rect.visible = i >= 0

	if i >= 0:
		var rect : Rect2 = line_container.get_child(i).get_global_rect()
		current_word_rect.global_position = rect.position
		current_word_rect.size = rect.size

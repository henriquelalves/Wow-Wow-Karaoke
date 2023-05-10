class_name LyricLine
extends Control

const HighlightLabel = preload("highlight_label.tscn")
const LyricLabel = preload("lyrics_label.tscn")

@onready var lyric_container: HBoxContainer = %LyricContainer
@onready var highlight_clip : Control = %HighlightClip
@onready var highlight_container: HBoxContainer = %HighlightContainer
@onready var highlight_control: Control = %HighlightControl

var _tween : Tween
var _playing : bool


func set_lyric_line(text_tokens: PackedStringArray, timestamps: Array[float], song_time: float) -> void:
	_clear()
	
	highlight_clip.size.x = 0.0
	for i in range(text_tokens.size()):
		var highlight_label := HighlightLabel.instantiate()
		highlight_container.add_child(highlight_label)
		highlight_label.text = text_tokens[i]
		
		var lyric_label := LyricLabel.instantiate()
		lyric_container.add_child(lyric_label)
		lyric_label.text = text_tokens[i]

	await get_tree().process_frame
	highlight_control.position = lyric_container.position
	
	var final_size := (highlight_container.get_child(0) as Control).size
	final_size.x = 0.0
	highlight_clip.size = final_size
	
	_playing = true
	await get_tree().create_timer(timestamps[0] - song_time).timeout
	_tween = create_tween()
	for i in range(timestamps.size() - 1):
		final_size.x += highlight_container.get_child(i).size.x + highlight_container.get("theme_override_constants/separation")
		_tween.tween_property(highlight_clip, "size", final_size, timestamps[i+1] - timestamps[i])
	_tween.tween_callback(func():
		_playing = false
		await get_tree().create_timer(1.0).timeout
		if not is_playing():
			_clear()
		)


func is_playing() -> bool:
	return _playing


func _clear() -> void:
	for child in highlight_container.get_children():
		child.free()
	
	for child in lyric_container.get_children():
		child.free()

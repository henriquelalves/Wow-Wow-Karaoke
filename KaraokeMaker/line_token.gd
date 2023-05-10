class_name LineToken
extends VBoxContainer


@onready var token_label: Label = %TokenLabel
@onready var timestamp_label: Label = %TimestampLabel


func set_token_label(str: String) -> void:
	token_label.visible = not str.is_empty()
	token_label.text = str


func set_timestamp_label(pos: float) -> void:
	timestamp_label.text = "%.02f" % pos

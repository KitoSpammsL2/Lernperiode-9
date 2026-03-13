extends Node2D

var time_elapsed: float = 0.0
var level_finished: bool = false

@onready var time_label: Label = $CanvasLayer/TimeLabel

func _process(delta: float) -> void:
	if not level_finished:
		time_elapsed += delta
	
	time_label.text = "Zeit: " + str(snapped(time_elapsed, 0.01))

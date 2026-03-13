extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body) -> void:
	if body.name == "Player":
		var game = get_node("/root/Game")
		game.level_finished = true
		print("Ziel erreicht in:", snapped(game.time_elapsed, 0.01))
		timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

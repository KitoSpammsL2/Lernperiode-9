extends Area2D

@onready var timer: Timer = $Timer

var dead := false
var player_to_respawn = null

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not dead:
		dead = true
		player_to_respawn = body
		print("You died!")
		Engine.time_scale = 0.5
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0

	if player_to_respawn != null:
		player_to_respawn.global_position = player_to_respawn.spawn_position
		player_to_respawn.velocity = Vector2.ZERO

	dead = false

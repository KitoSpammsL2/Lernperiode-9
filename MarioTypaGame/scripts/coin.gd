extends Area2D



func _on_body_entered(body):
	if body.name == "Player":
		get_node("/root/Game/BackendClient").add_coins(1)
		queue_free()
	

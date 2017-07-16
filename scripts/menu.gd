extends Node2D

func _ready():
	pass

func _on_play_pressed():
	get_node("sound").play("player_explode")
	var t = Timer.new()
	t.set_wait_time(2.1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	get_tree().change_scene("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit()

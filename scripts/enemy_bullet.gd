extends Area2D

var direction = Vector2(0, 0)
export var damage = 20
var speed = 300

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	var position = get_node(".").get_pos()
	position += direction * speed * delta
	if (position.x < 0 || position.x > 1920 || position.y < 0 || position.y > 1080):
		queue_free()
	get_node(".").set_pos(position)



func _on_enemy_bullet_area_enter( area ):
	if (area extends preload("res://scripts/player.gd") and !area.dying):
		area.hit_player(damage)
		queue_free()

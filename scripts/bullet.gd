extends Area2D

var direction = Vector2(0, 0)
var velocity = 1250
var damage = 1
var player = null
var destroyed = false


func _ready():
	player = get_tree().get_root().get_node("game/player")
	direction.x = cos(get_node(".").get_rot())
	direction.y = -sin(get_node(".").get_rot())
	set_fixed_process(true)
	
func _fixed_process(delta):
	var position = get_node(".").get_pos()
	position += direction * velocity * delta
	if (position.x < 0 || position.x > 1920 || position.y < 0 || position.y > 1080):
		queue_free()
	get_node(".").set_pos(position)



func _on_bullet_area_enter( area ):
	if (area.has_method("lower_health") and area.can_interact and !destroyed):
		area.lower_health(damage)
		player.change_health(damage)
		destroyed = true
		queue_free()

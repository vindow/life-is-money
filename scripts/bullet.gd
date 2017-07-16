extends Area2D

var direction = Vector2(0, 0)
var velocity = 1250
var damage = 1


func _ready():
	direction.x = cos(get_node(".").get_rot())
	direction.y = -sin(get_node(".").get_rot())
	set_fixed_process(true)
	
func _fixed_process(delta):
	var position = get_node(".").get_pos()
	position += direction * velocity * delta
	if (position.x < 0 || position.x > 1920 || position.y < 0 || position.y > 1080):
		queue_free()
	get_node(".").set_pos(position)


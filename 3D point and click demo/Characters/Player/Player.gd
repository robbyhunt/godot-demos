extends Position3D

onready var movement_controller = get_node("MovementController")
onready var scene_base = get_owner()
onready var camera_controller = scene_base.get_node("CameraController")
onready var camera = camera_controller.get_node("Tripod/Camera")

var is_moving
var interact_on_arrive


func _ready():
	movement_controller.connect("destination_reached", self, "_on_destination_reached")


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if InteractionManager.is_mouse_hovering:
			move_to_position(InteractionManager.object_hovered.interact_spot_global_pos, true)
		else:
			move_to_position(get_click_pos(event))


func move_to_position(destination, interact = false):
	interact_on_arrive = interact
	if interact:
		InteractionManager.queue_object()
	if movement_controller.set_destination(destination):
		$AnimationPlayer.play("move", -1, 1.5)


func get_click_pos(event):
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position)*100
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self], 1)
	print(result.position)
	return result.position

func _on_destination_reached():
	$AnimationPlayer.play("idle", .2, 1)
	if interact_on_arrive:
		interact_on_arrive = false
		InteractionManager.interact()

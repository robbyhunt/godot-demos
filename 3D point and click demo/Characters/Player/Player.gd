extends Position3D

onready var movement_controller = get_node("MovementController")
onready var game_camera = get_owner().get_node("CameraController").get_node("Tripod/Camera")

var look_at_loc
var interact_on_arrive = false


func _ready():
	movement_controller.connect("destination_reached", self, "_on_destination_reached")


func _process(_delta):
	look_at_loc = game_camera.global_transform.origin
	$Model.look_at(Vector3(look_at_loc.x, self.global_transform.origin.y, look_at_loc.z), Vector3.UP)


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if InteractionManager.object_interacting:
			InteractionManager.end_interaction()
		if InteractionManager.object_queued:
			InteractionManager.clear_queued()
		
		if InteractionManager.object_hovered:
			move_to_position(InteractionManager.object_hovered.interact_spot_global_pos, true)
		else:
			move_to_position(get_click_pos(event))


func get_click_pos(event):
	var from = game_camera.project_ray_origin(event.position)
	var to = from + game_camera.project_ray_normal(event.position)*100
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self], 1)
	return result.position


func move_to_position(destination, interact = false):
	interact_on_arrive = interact
	if interact:
		InteractionManager.queue_object()
	if movement_controller.set_destination(destination):
		$AnimationPlayer.play("move", -1, 1.5)


func _on_destination_reached():
	$AnimationPlayer.play("idle", .2, 1)
	if interact_on_arrive:
		interact_on_arrive = false
		InteractionManager.interact()


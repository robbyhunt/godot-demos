extends Position3D

onready var movement_controller = get_node("MovementController")
onready var game_camera = get_owner().get_node("CameraController").get_node("Tripod/Camera")
onready var dialogue_pos = get_node("DialogueSpot")

var look_at_loc
var interact_on_arrive = false


func _ready():
	movement_controller.connect("destination_reached", self, "_on_destination_reached")
	
	InteractionManager.player_ref = self


func _process(_delta):
	look_at_loc = game_camera.global_transform.origin
	$Model.look_at(Vector3(look_at_loc.x, self.global_transform.origin.y, look_at_loc.z), Vector3.UP)


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if InteractionManager.object_interacting:
			InteractionManager.end_interaction()
		if InteractionManager.object_queued:
			interact_on_arrive = false
			InteractionManager.clear_queued()
		
		if InteractionManager.object_hovered:
			interact(InteractionManager.object_hovered)
		else:
			var click_pos = get_click_pos(event)
			if click_pos:
				move_to_position(click_pos)
			else:
				print("Invalid move pos")


func get_click_pos(event: InputEventMouseButton):
	var from = game_camera.project_ray_origin(event.position)
	var to = from + game_camera.project_ray_normal(event.position)*100
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self], 1)
	
	if result:
		return result.position
	else:
		return false


func move_to_position(destination, stop_range: float = 0):
	if movement_controller.set_destination(destination, stop_range):
		$AnimationPlayer.play("move", -1, 1.5)


func interact(interact_object):
	var target_pos = interact_object.interact_spot_global_pos
	var player_pos = self.global_transform.origin
	var distance_between = player_pos.distance_to(target_pos)
	var target_max_range = interact_object.interact_range
	
	InteractionManager.queue_object()
	if distance_between > target_max_range:
		interact_on_arrive = true
		move_to_position(target_pos, target_max_range)
	else:
		InteractionManager.interact()


func _on_destination_reached():
	$AnimationPlayer.play("idle", .2, 1)
	if interact_on_arrive:
		interact_on_arrive = false
		InteractionManager.interact()


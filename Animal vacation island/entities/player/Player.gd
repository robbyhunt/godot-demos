extends KinematicBody

class_name Player

# MOVEMENT VARIABLES
var direction: Vector3
var velocity: Vector3
var acceleration
var vertical_velocity = 0
var gravity = 25
var movement_speed = 0
var jumping: bool = false
export(float) var walk_speed = 3
export(float) var run_speed = 8
export(int) var base_acceleration = 5
export(int) var jump_velocity = 9

# INTERACT VARIABLES
var cur_entity_in_area = null
var last_entity_entered_area = null

# GLOBE SHADER VARIABLES
var shader_radius = GameData.globe_shader_radius
var shader_origin_offset = GameData.globe_shader_origin_offset
onready var focal_point = get_node("FocalPoint")

var acting = false

# GET_NODE VARIABLES
onready var anim_tree = $Mesh/AnimationTree


func _ready():
	# warning-ignore:return_value_discarded
	GameEvents.connect("state_changed", self, "_on_state_changed")
	
	for node in get_tree().get_nodes_in_group("globe_shader"):
		for surface_count in node.get_surface_material_count():
			node.get_surface_material(surface_count).set_shader_param("active", true)
			node.get_surface_material(surface_count).set_shader_param("radius", shader_radius)

func _process(_delta):
	if GameState.state == GameState.STATES.FREEWALK and !acting:
		if Input.is_action_just_pressed("interact") and cur_entity_in_area:
			interact(cur_entity_in_area)
	
	update_globe_shader()
	


func _physics_process(delta):
	if GameState.state == GameState.STATES.FREEWALK and !acting:
		acceleration = base_acceleration
		
		if Input.is_action_pressed("move_forward") || Input.is_action_pressed("move_back") || Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
			direction = Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0, Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
			direction = direction.normalized()
			
			if Input.is_action_pressed("sprint"):
				movement_speed = run_speed
				anim_tree.set("parameters/iwr_blend/blend_amount", lerp(anim_tree.get("parameters/iwr_blend/blend_amount"), 1, delta * acceleration / 2))
			else:
				movement_speed = walk_speed
				anim_tree.set("parameters/iwr_blend/blend_amount", lerp(anim_tree.get("parameters/iwr_blend/blend_amount"), 0, delta * acceleration / 2))
		else:
			anim_tree.set("parameters/iwr_blend/blend_amount", lerp(anim_tree.get("parameters/iwr_blend/blend_amount"), -1, delta * acceleration / 2))
			movement_speed = 0
	
	# rotate player model to face movemend direction
	$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(direction.x, direction.z), delta * 5)
	
	velocity = lerp(velocity, direction * movement_speed, delta * acceleration)
	
	if move_and_slide(velocity + Vector3.DOWN * vertical_velocity, Vector3.UP):
		pass
	
	# handle falling/jumping
	if !is_on_floor():
		vertical_velocity += gravity * delta
	else:
		if Input.is_action_just_pressed("jump") and GameState.state == GameState.STATES.FREEWALK and !jumping:
			jumping = true
			anim_tree.set("parameters/jump/active", true)
			yield(get_tree().create_timer(.25), "timeout")
			jumping = false
			vertical_velocity = -abs(jump_velocity)
		else:
			vertical_velocity = 1
	
	## BLEND RUN WITH WALK DEPENDING ON VELOCITY TO STOP SPRINTING IN CIRCLES WHEN ROTATING
	var iw_blend = (velocity.length() - walk_speed) / walk_speed
	var wr_blend = (velocity.length() - walk_speed) / (run_speed - walk_speed)
	if velocity.length() <= walk_speed:
		anim_tree.set("parameters/iwr_blend/blend_amount", iw_blend)
	else:
		anim_tree.set("parameters/iwr_blend/blend_amount", wr_blend)


func update_globe_shader():
	# UPDATE ALL MATERIALS WHICH HAVE THE CYLINDER WORLD SHADER WITH THE CURRENT PLAYER POSITION
	var origin = global_transform.origin + shader_origin_offset
	for node in get_tree().get_nodes_in_group("globe_shader"):
		var distance = node.global_transform.origin.distance_to(focal_point.global_transform.origin)
		if distance < 60 or node.name == "Ground":			
			for surface_count in node.get_surface_material_count():
				node.get_surface_material(surface_count).set_shader_param("origin", origin)
			
			var cur_aabb = node.global_transform.xform(node.mesh.get_aabb())
			var cur_aabb_corners = [
				Vector2(cur_aabb.position.z, cur_aabb.position.y),
				Vector2(cur_aabb.position.z, cur_aabb.end.y),
				Vector2(cur_aabb.end.z, cur_aabb.position.y),
				Vector2(cur_aabb.end.z, cur_aabb.end.y),
			]
			var final_pos = Vector2.ONE * INF
			var final_end = -Vector2.ONE * INF
			
			for corner in cur_aabb_corners:
				var angle = clamp((corner.x - origin.z) / shader_radius, -PI*0.5, PI*0.5)
				var excess = (corner.x - origin.z) - angle * shader_radius 
				var radial = Vector2(0, 1).rotated(-angle)
				var new_pos = Vector2(origin.z, origin.y) + radial * (corner.y - origin.y)
				new_pos.y -= abs(excess)
				final_pos.x = min(final_pos.x, new_pos.x)
				final_pos.y = min(final_pos.y, new_pos.y)
				final_end.x = max(final_end.x, new_pos.x)
				final_end.y = max(final_end.y, new_pos.y)
			if final_pos.x < origin.z and final_end.x > origin.z:
				final_pos.y = cur_aabb.position.y
			
			var new_aabb = AABB(Vector3(cur_aabb.position.x, final_pos.y, final_pos.x), Vector3(cur_aabb.size.x, final_end.y - final_pos.y, final_end.x - final_pos.x))
			node.set_custom_aabb(node.global_transform.xform_inv(new_aabb))


func interact(entity):
	if is_instance_valid(entity):
		if entity is NPC:
			talk(entity)
		elif entity is TreeProp:
			shake_tree(entity)
		elif entity is Campfire:
			entity.toggle_fire()
		elif entity is DigSpot:
			dig(entity)
		elif entity is Item:
			pickup(entity)
		direction = translation.direction_to(cur_entity_in_area.translation)
		movement_speed = 0


func talk(entity):
	GameState.change_state(GameState.STATES.TALK)
	GameEvents.emit_signal("dialogue_start", entity, self)
	entity.on_talk(translation)


func shake_tree(tree):
	tree.connect("shake_end", self, "finished_action")
	acting = true
	tree.shake()


func dig(spot):
	spot.connect("dig_end", self, "finished_action")
	acting = true
	anim_tree.set("parameters/dig/active", true)
	spot.dig()


func pickup(item):
	acting = true
	GameEvents.emit_signal("item_pickup", item)
	anim_tree.set("parameters/dig/active", true)
	yield(get_tree().create_timer(1.15), "timeout")
	acting = false


func finished_action(prop, signal_name):
	prop.disconnect(signal_name, self, "finished_action")
	acting = false


func on_dialogue_end():
	pass


func _on_state_changed():
	movement_speed = 0


func _on_InteractArea_body_entered(body):
	if cur_entity_in_area:
		last_entity_entered_area = cur_entity_in_area
	cur_entity_in_area = body
	if cur_entity_in_area.has_method("show_interactable"):
		cur_entity_in_area.show_interactable()
	if last_entity_entered_area and last_entity_entered_area != body:
		if is_instance_valid(last_entity_entered_area) and last_entity_entered_area.has_method("hide_interactable"):
			last_entity_entered_area.hide_interactable()


func _on_InteractArea_body_exited(body):
	if body == cur_entity_in_area:
		last_entity_entered_area = cur_entity_in_area
		if $Mesh/InteractArea.get_overlapping_bodies():
			cur_entity_in_area = $Mesh/InteractArea.get_overlapping_bodies()[0]
			if cur_entity_in_area.has_method("show_interactable"):
				cur_entity_in_area.show_interactable()
		else:
			cur_entity_in_area = null
	elif body == last_entity_entered_area:
		last_entity_entered_area = null
	
	if body.has_method("hide_interactable"):
		body.hide_interactable()

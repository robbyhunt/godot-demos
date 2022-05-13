extends RigidBody

export var max_ang = 20
export var max_vel = 4
var intitial_position = Vector3()

var collision_force : Vector3 = Vector3.ZERO
var upmost_face = 0

onready var audio: AudioStreamPlayer = $AudioStreamPlayer
onready var audio2: AudioStreamPlayer = $AudioStreamPlayer2
onready var audio3: AudioStreamPlayer = $AudioStreamPlayer2

func _ready():
	intitial_position = global_transform.origin


func _physics_process(delta):
	if mode == MODE_RIGID:
		get_result()
		
		if linear_velocity.length() < 0.05 and angular_velocity.length() < 0.05:
			mode = MODE_STATIC


func _integrate_forces(state : PhysicsDirectBodyState)->void:
	collision_force = Vector3.ZERO
	for i in range(state.get_contact_count()):
		collision_force += state.get_contact_impulse(i) * state.get_contact_local_normal(i)
	
	if collision_force.x > 0.5:
		play_sound(collision_force.x, 1)
	if collision_force.y > 0.5:
		play_sound(collision_force.y, 2)
	if collision_force.z > 0.5:
		play_sound(collision_force.z, 3)


func throw():
	mode = MODE_RIGID
	
	global_transform.origin = intitial_position
	
	var random_ang = Vector3(
		rand_range(-max_ang,max_ang),
		rand_range(-max_ang,max_ang),
		rand_range(-max_ang,max_ang)
	)
	angular_velocity = random_ang
	
	var random_vel = Vector3(
		rand_range(-max_vel,max_vel),
		rand_range(0,4),
		rand_range(-max_vel,max_vel)
	)
	linear_velocity = random_vel


func get_result():
	var max_upness = 0.0
	
	for n in $Normals.get_children():
		var normal = n.global_transform.basis.y
		var upness = normal.dot(Vector3.UP) # how much it's facing up.
		if upness > max_upness:
			max_upness = upness
			upmost_face = n.face


func play_sound(force, player_id):
	var volume = clamp(-5 + (force * 2), -5, 5)
	match player_id:
		1:
			audio.set_volume_db(volume)
			audio.play()
		2:
			audio2.set_volume_db(volume)
			audio2.play()
		3:
			audio3.set_volume_db(volume)
			audio3.play()


func _on_die_sleeping_state_changed():
	print(sleeping)

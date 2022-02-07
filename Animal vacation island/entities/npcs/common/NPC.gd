extends KinematicBody

class_name NPC

export(String) var npc_name

var talking = false
var face_dir: Vector3
var original_dir: float


func _physics_process(delta):
	if talking:
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(face_dir.x,face_dir.z), delta * 5)
	else:
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, original_dir, delta * 5)


func show_interactable():
	$InteractIcon.show()


func hide_interactable():
	$InteractIcon.hide()


func on_talk(position_to_face):
	original_dir = $Mesh.rotation.y
	face_dir = translation.direction_to(position_to_face)
	talking = true


func on_dialogue_end():
	talking = false
	face_dir = Vector3(0, 0, 0)


func play_anim(name: String):
	$Mesh/AnimationTree.set("parameters/" + name + "/active", true)

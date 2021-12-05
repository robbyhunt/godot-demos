# Hold and plays the base animation for battlers.
tool
class_name BattlerAnim
extends Spatial

signal animation_finished(name)
# Emitted by animations when a combat action should apply its next effect, like dealing damage or healing an ally.
# warning-ignore:unused_signal
signal triggered

enum Direction { LEFT, RIGHT }

# Controls the direction in which the battler looks and moves.
export (Direction) var direction := Direction.RIGHT setget set_direction

onready var anim_player: AnimationPlayer = $Pivot/AnimationPlayer
onready var anim_player_damage: AnimationPlayer = $Pivot/AnimationPlayerDamage
onready var anchor_front: Spatial = $FrontAnchor
onready var anchor_top: Spatial = $TopAnchor
onready var tween: Tween = $Tween
onready var battler_base = get_parent()


func combat_init(target_posit: Vector3, enemy_posit: Vector3):
	# Look at target move position, then move to it
	battler_base.look_at(target_posit, Vector3.UP)
	tween.interpolate_property(battler_base, "global_transform:origin", battler_base.global_transform.origin, target_posit, 2, Tween.TRANS_QUAD)
	tween.start()
	yield(tween, "tween_completed")
	
	# I need to know the target rotation_degrees but idk how to do that without applying the altered transform.
	# Tweening the transform gives a weird effect so I'm setting the new transform, grabbing the rot value,
	# then setting the og transform back BEFORE tweening to rotate. I know this is terrible but it's temporary lol.
	# REPLACE
	var start_transform = battler_base.global_transform
	var target_transform = battler_base.global_transform.looking_at(enemy_posit, Vector3.UP)
	battler_base.global_transform = target_transform
	var target_rot = battler_base.rotation_degrees
	battler_base.global_transform = start_transform
	# Smooth look at the enemy position
	tween.interpolate_property(battler_base, "rotation_degrees", battler_base.rotation_degrees, target_rot, 1, Tween.TRANS_QUAD)
	tween.start()


func play(anim_name: String) -> void:
	if anim_name == "take_damage":
		anim_player_damage.play(anim_name)
		anim_player_damage.seek(0.0)
	else:
		anim_player.play(anim_name)


func get_front_anchor_global_transform() -> Transform:
	return anchor_front.global_transform


func get_top_anchor_global_transform() -> Transform:
	return anchor_top.global_transform


func is_playing() -> bool:
	return anim_player.is_playing()


func queue_animation(anim_name: String) -> void:
	anim_player.queue(anim_name)
	if not anim_player.is_playing():
		anim_player.play()


func move_forward() -> void:
	print(get_parent().name + " has stepped forward.")


func move_back() -> void:
	print(get_parent().name + " has stepped back.")



func set_direction(value: int) -> void:
	direction = value
	#scale.x = -1.0 if direction == Direction.RIGHT else 1.0


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished", anim_name)

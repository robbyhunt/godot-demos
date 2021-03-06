# In-game arrow to select target battlers. Appears when the player selected an action and has to pick a target for it.
class_name UISelectBattlerArrow
extends Position3D

# Emitted when the player pressed `ui_accept` or `ui_cancel`.
signal target_selected(battler)

# Duration of the tween that moves the arrow to another target in seconds.
export var move_duration: float = 0.1

# Targets that the player can select. Array[Battler]
var _targets: Array
# Battler at which the arrow is currently pointing. If the player presses `ui_accept`, this battler will be selected.
var _target_current: Battler setget _set_target_current

onready var _tween = $Tween


func _init() -> void:
	set_as_toplevel(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		emit_signal("target_selected", [_target_current])
	elif event.is_action_pressed("ui_cancel"):
		emit_signal("target_selected", [])

	var new_target: Battler
	var direction := Vector3.ZERO
	if event.is_action_pressed("ui_left"):
		direction = Vector3(0, 0, -1)
	elif event.is_action_pressed("ui_up"):
		direction = Vector3(0, -1, 0)
	elif event.is_action_pressed("ui_right"):
		direction = Vector3(0, 0, 1)
	elif event.is_action_pressed("ui_down"):
		direction = Vector3(0, 1, 0)

	if direction != Vector3.ZERO:
		new_target = _find_closest_target(direction)
		if new_target:
			_set_target_current(new_target)


func setup(battlers: Array) -> void:
	show()
	_targets = battlers

	_target_current = _targets[0]
	scale.x = 1.0 if _target_current.is_party_member else -1.0
	global_transform = _target_current.battler_anim.get_front_anchor_global_transform()


func _move_to(target_transform: Transform):
	if _tween.is_active():
		_tween.stop_all()
	_tween.interpolate_property(
		self,
		'global_transform',
		global_transform,
		target_transform,
		move_duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	_tween.start()


# Returns the closest target in the given direction.
# Returns null if there is no other target in the direction.
func _find_closest_target(direction: Vector3) -> Battler:
	var selected_target: Battler
	var distance_to_selected: float = INF

	var candidates := []
	for battler in _targets:
		if battler == _target_current:
			continue
		var to_battler: Vector3 = battler.global_transform.origin.direction_to(_target_current.global_transform.origin) 
		if abs(direction.angle_to(to_battler)) < PI / 3.0:
			candidates.append(battler)

	for battler in candidates:
		var distance := global_transform.origin.distance_to(battler.global_transform.origin)
		if distance < distance_to_selected:
			selected_target = battler
			distance_to_selected = distance

	return selected_target


func _set_target_current(value: Battler) -> void:
	_target_current = value
	_move_to(_target_current.battler_anim.get_front_anchor_global_transform())

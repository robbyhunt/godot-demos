# Animated label displaying amounts of damage, healing, armor damage, or energy gained.
class_name UIDamageLabel
extends Position3D

enum Types { HEAL, DAMAGE, ARMOR, ENERGY }

const COLOR_TRANSPARENT := Color(1.0, 1.0, 1.0, 0.0)

export var color_damage := Color("#b0305c")
export var color_heal := Color("#3ca370")
export var color_armor := Color("#f2a65e")
export var color_energy := Color("#4da6ff")

var _color: Color setget _set_color
var _amount := 0

onready var _label: Label = $Viewport/Label
onready var _tween: Tween = $Tween
onready var _sprite: Sprite3D = $Sprite3D


func setup(type: int, amount: int) -> void:
	_amount = amount
	
	match type:
		Types.DAMAGE:
			_set_color(color_damage)
		Types.HEAL:
			_set_color(color_heal)
		Types.ENERGY:
			_set_color(color_energy)
		Types.ARMOR:
			_set_color(color_armor)


func _ready() -> void:
	_label.text = str(_amount)


func _set_color(value: Color) -> void:
	_color = value
	if not is_inside_tree():
		yield(self, "ready")
	_label.modulate = _color


func animate() -> void:
	var side_movement = randi() % 3 - 1.5
	_tween.interpolate_property(
		self,
		"translation",
		translation,
		Vector3(translation.x, translation.y + 1.25, translation.z + side_movement),
		0.8,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	_tween.interpolate_property(
		_sprite, "modulate", _sprite.modulate, COLOR_TRANSPARENT, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.3
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	queue_free()

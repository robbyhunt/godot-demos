extends Area
class_name BattlerAgro

var enabled = true setget _set_enabled


func _ready():
	if !enabled:
		monitoring = false


func _on_BattlerAgro_body_entered(body):
	if enabled:
		if body.ai_scene == null:
			enabled = false
			Events.emit_signal("setup_combat", self.get_parent(), body)


func _set_enabled(value):
	enabled = value
	monitoring = value

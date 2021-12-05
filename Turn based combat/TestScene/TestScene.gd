extends Spatial

const CombatScene: PackedScene = preload("res://CombatSystem/CombatDemo.tscn")

var _player_battler: Battler
var _combat_scene: CombatScene


func _ready():
	Events.connect("setup_combat", self, "_on_setup_combat")


func _on_setup_combat(enemy_battler: Battler, player_battler: Battler):
	_player_battler = player_battler
	
	# Instance new combat scene and add it to world at enemy battler's position
	var new_combat = CombatScene.instance()
	new_combat.transform.origin = enemy_battler.global_transform.origin
	add_child(new_combat)
	_combat_scene = new_combat
	
	# Connect to end of combat signal from new combat scene to determine what happens after
	new_combat.connect("combat_ended", self, "_on_combat_end")
	
	# Spawn a new camera at the player's camera location, then move it to the battle camera position and set it active
	var player_camera_posit = player_battler.get_node("Controller/InnerGimbal/Camera").global_transform
	var new_camera = Camera.new()
	var new_tween = Tween.new()
	new_tween.name = "Tween"
	new_camera.add_child(new_tween)
	new_camera.global_transform = player_camera_posit
	new_camera.name = "CombatCamera"
	new_combat.add_child(new_camera)
	new_camera.set_current(true)
	new_tween.interpolate_property(new_camera, "global_transform", player_camera_posit, new_combat.camera.global_transform, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	new_tween.start()
	
	# Disable player controller and move battlers to battle position, then have them look at each other
	player_battler.combat_init(new_combat.get_node("Player").global_transform.origin, new_combat.get_node("Enemy").global_transform.origin)
	enemy_battler.combat_init(new_combat.get_node("Enemy").global_transform.origin, new_combat.get_node("Player").global_transform.origin)
	
	# Start combat nodes setup + init battle
	new_combat.setup([enemy_battler, player_battler])


func _on_combat_end(result: String):
	if result == "Victory":
		var tween = _combat_scene.get_node("CombatCamera/Tween")
		var camera = _combat_scene.get_node("CombatCamera")
		var player_camera = _player_battler.get_node("Controller/InnerGimbal/Camera")
		tween.interpolate_property(camera, "global_transform", camera.global_transform, player_camera.global_transform, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_completed")
		_player_battler.end_combat()
		_combat_scene.queue_free()
		_combat_scene = null
		_player_battler = null

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
	
	# Disable player controller and move battlers to battle position, then have them look at each other
	player_battler.battle_posit_setup(new_combat.get_node("Player").global_transform.origin, new_combat.get_node("Enemy").global_transform.origin)
	enemy_battler.battle_posit_setup(new_combat.get_node("Enemy").global_transform.origin, new_combat.get_node("Player").global_transform.origin)
	
	new_combat.setup([enemy_battler, player_battler])


func _on_combat_end(result: String):
	if result == "Victory":
		yield(get_tree().create_timer(2.0), "timeout")
		_player_battler.end_combat()
		_combat_scene.queue_free()

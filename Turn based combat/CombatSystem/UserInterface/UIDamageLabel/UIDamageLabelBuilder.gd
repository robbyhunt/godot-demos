# Spawns labels that display damage, healing, or missed hits.
class_name UIDamageLabelBuilder
extends Node

export var damage_label_scene: PackedScene = preload("UIDamageLabel.tscn")
export var miss_label_scene: PackedScene = preload("UIMissedLabel.tscn")

var _active_turn_queue: ActiveTurnQueue


func setup(battlers: Array, active_turn_queue: ActiveTurnQueue) -> void:
	_active_turn_queue = active_turn_queue
	for battler in battlers:
		battler.connect("damage_taken", self, "_on_Battler_damage_taken", [battler])
		battler.connect("hit_missed", self, "_on_Battler_hit_missed", [battler])
		

func _on_Battler_damage_taken(amount: int, target: Battler) -> void:
	var label: UIDamageLabel = damage_label_scene.instance()
	label.setup(UIDamageLabel.Types.DAMAGE, target.battler_anim.get_top_anchor_global_transform(), amount)
	_active_turn_queue.add_child(label)


func _on_Battler_hit_missed(target: Battler) -> void:
	print("fix miss labels")
	var label = miss_label_scene.instance()
	_active_turn_queue.add_child(label)
	label.global_transform = target.battler_anim.get_top_anchor_global_transform()

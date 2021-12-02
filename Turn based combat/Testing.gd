extends Node

var stats = BattlerStats.new()


func _ready():
	stats.base_attack = 100


func add_value():
	stats.add_value_modifier("attack", 10)


func add_rate():
	stats.add_rate_modifier("attack", 0.5)


func print_stat():
	print(stats.attack)

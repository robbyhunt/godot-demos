# Stores and manages the battler's base stats like health, energy, and base
# damage.
extends Resource
class_name BattlerStats

signal health_depleted
signal health_changed(old_value, new_value)
signal energy_changed(old_value, new_value)

const UPGRADABLE_STATS = [
	"max_health", "max_energy", "attack", "defense", "speed", "hit_chance", "evasion"
]

export var max_health := 100.0
export var max_energy := 6

export var base_attack := 10.0 setget set_base_attack
export var base_defense := 10.0 setget set_base_defense
export var base_speed := 70.0 setget set_base_speed
export var base_hit_chance := 100.0 setget set_base_hit_chance
export var base_evasion := 0.0 setget set_base_evasion

var health := max_health setget set_health
var energy := 0 setget set_energy

var attack := base_attack
var defense := base_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion

var _modifiers := {}


func _init() -> void:
	for stat in UPGRADABLE_STATS:
		_modifiers[stat] = {
			value = {},
			rate = {}
		}


func reinitialize() -> void:
	set_health(max_health)


func add_value_modifier(stat_name: String, value: float) -> void:
	_add_modifier(stat_name, value, 0.0)


func add_rate_modifier(stat_name: String, rate: float) -> void:
	_add_modifier(stat_name, 0.0, rate)


func _add_modifier(stat_name: String, value: float, rate := 0.0) -> int:
	assert(stat_name in UPGRADABLE_STATS, "Trying to add a modifier to a nonexistent stat.")
	var id := -1

	# If the argument `value` is not `0.0`, we register a value-based modifier.
	if not is_equal_approx(value, 0.0):
		# Generates a new unique id for the "value" key.
		id = _generate_unique_id(stat_name, true)
		_modifiers[stat_name]["value"][id] = value
	# If the argument `value` is not `0.0`, we register a rate-based modifier.
	if not is_equal_approx(rate, 0.0):
		# Generates a new unique id for the "rate" key.
		id = _generate_unique_id(stat_name, false)
		_modifiers[stat_name]["rate"][id] = rate

	_recalculate_and_update(stat_name)
	return id


func remove_modifier(stat_name: String, is_value_modifier: bool, id: int) -> void:
	if is_value_modifier:
		assert(id in _modifiers[stat_name]["value"], "Stat value modifier id " + String(id) + " not found for " + stat_name + ".")
		_modifiers[stat_name]["value"].erase(id)
	else: # is rate modifier
		assert(id in _modifiers[stat_name]["rate"], "Stat rate modifier id " + String(id) + " not found for " + stat_name + ".")
		_modifiers[stat_name]["rate"].erase(id)
	
	_recalculate_and_update(stat_name)


func set_health(value: float) -> void:
	var health_previous := health
	health = clamp(value, 0.0, max_health)
	emit_signal("health_changed", health_previous, health)
	if is_equal_approx(health, 0.0):
		emit_signal("health_depleted")


func set_energy(value: int) -> void:
	var energy_previous := energy
	energy = int(clamp(value, 0.0, max_energy))
	emit_signal("energy_changed", energy_previous, energy)


func set_base_attack(value: float) -> void:
	base_attack = value
	_recalculate_and_update("attack")


func set_base_defense(value: float) -> void:
	base_defense = value
	_recalculate_and_update("defense")


func set_base_speed(value: float) -> void:
	base_speed = value
	_recalculate_and_update("speed")


func set_base_hit_chance(value: float) -> void:
	base_hit_chance = value
	_recalculate_and_update("hit_chance")


func set_base_evasion(value: float) -> void:
	base_evasion = value
	_recalculate_and_update("evasion")


func _recalculate_and_update(stat: String) -> void:
	var value: float = get("base_" + stat)

	# We first get and sum all rate-based multipliers.
	var modifiers_multiplier: Array = _modifiers[stat]["rate"].values()
	var multiplier := 1.0
	for modifier in modifiers_multiplier:
		multiplier += modifier
	# Then, we multiply the base stat's value, if necessary.
	if not is_equal_approx(multiplier, 1.0):
		value *= multiplier

	# And we add all value-based modifiers.
	var modifiers_value: Array = _modifiers[stat]["value"].values()
	for modifier in modifiers_value:
		value += modifier

	value = round(max(value, 0.0))
	set(stat, value)


func _generate_unique_id(stat_name: String, is_value_modifier: bool) -> int:
	var type := "value" if is_value_modifier else "rate"
	var keys: Array = _modifiers[stat_name][type].keys()
	if keys.empty():
		return 0
	else:
		return keys.back() + 1

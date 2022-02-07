extends Node

var globe_shader_radius = 80
var globe_shader_origin_offset = Vector3(0, -80, 0)

var player_inv = {}

var item_db = {
	"apple": {
		"stackable": true,
		"max_stack": 10,
		"asset": "res://ui/inventory/assets/items/apple.png"
	},
	"error": {
		"stackable": true,
		"max_stack": 100,
		"asset": "res://scenes/assets/water.png"
	}
}

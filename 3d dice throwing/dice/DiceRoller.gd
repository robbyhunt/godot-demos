extends Spatial

var dice_scene = preload("res://dice/Die6.tscn")


func roll_dice(qty = 1):
	for die in $Dice.get_children():
		die.queue_free()
	
	for die in qty:
		var dice_instance = dice_scene.instance()
		$Dice.add_child(dice_instance)
		dice_instance.throw()


func _on_button_pressed(dice_qty):
	roll_dice(dice_qty)

extends Node
@onready var sprite_2d: Sprite2D = $Sprite2D


func _on_button_pressed() -> void:
	var ads = GodotADS.new()
	print(ads.read_var())
	ads.get_var_list()

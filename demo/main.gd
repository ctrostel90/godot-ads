extends Node2D

func _ready() -> void:
	var ads = GodotADS.new()
	print(ads.try_connect())

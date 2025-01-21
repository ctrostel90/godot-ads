extends CanvasLayer
signal clicked
signal connect_axes

func _on_button_pressed() -> void:
	#godot_ads.get_var_list()
	clicked.emit()



func _on_check_button_toggled(toggled_on: bool) -> void:
	connect_axes.emit(toggled_on)

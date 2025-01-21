extends Node3D

@onready var godot_ads: GodotADS = $GodotADS
@onready var label: Label = $GodotADS/Label
@onready var scara_s_cczc: Scara_S_SSCZ = $Scara_S_CCZC

var reading = false


func _process(_delta: float) -> void:
	if reading:
		scara_s_cczc.EnableKinematic = true
		scara_s_cczc.Q1 = godot_ads.get_q1()
		scara_s_cczc.Q2 = godot_ads.get_q2()
		scara_s_cczc.Q3 = godot_ads.get_q3() / 1000.0
		scara_s_cczc.Q4 = godot_ads.get_q4() 


func _on_canvas_layer_clicked() -> void:
	godot_ads.get_var_list($CanvasLayer/Tree2 as Tree)
	


func _on_button_2_pressed() -> void:
	var tree = $CanvasLayer/Tree2 as Tree
	tree.visible = not tree.visible


func _on_canvas_layer_connect_axes(toggled_on:bool) -> void:
	if toggled_on:
		reading = true
		godot_ads.start_pos_read()
	else:
		reading = false
		godot_ads.end_pos_read()

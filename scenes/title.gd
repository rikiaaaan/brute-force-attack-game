extends Node


func _on_start_button_pressed() -> void:
	get_parent().change_scene("play")
	return


func _on_rule_button_pressed() -> void:
	get_parent().change_scene("howtoplay")
	return

extends Node

#最も大事な変数 答え
var answer:int = 0
var current_input:Array[int] = [-1, -1, -1, -1]
var number_button_pressed_counter:int = 0

var time_elapsed:float = 0.0

var number_button_total_pressed_count:int = 0
var enter_button_total_pressed_count:int = 0
var back_button_total_pressed_count:int = 0

var game_finished:bool = false


func _ready() -> void:
	#答えの設定
	answer = randi_range(5, 9994)
	$ResultLayer.hide()
	return


func _process(delta:float) -> void:
	if !game_finished:
		time_elapsed += delta
		%TimeElapsedLabel.text = "%02d:%02d:%02d" % [int( time_elapsed / 3600 ), int( (int(time_elapsed) % 3600) / 60 ), int(time_elapsed) % 60]
	return


func _input(event:InputEvent) -> void:
	if get_parent().debug_mode:
		if event.is_action_pressed("debug_force_incorrect"):
			$AnimationPlayer.play("password_incorrect")
		if event.is_action_pressed("debug_force_open") && !game_finished:
			back_button_total_pressed_count = -1
			enter_button_total_pressed_count = -1
			number_button_total_pressed_count = -1
			time_elapsed = 11*3600 + 45*60 + 14
			$AnimationPlayer.play("password_correct")
			game_finished = true
			await $AnimationPlayer.animation_finished
			play_ending()
		pass
	return


func set_result_ui() -> void:
	var t:float = time_elapsed
	%ElapsedTime.text = "%02d:%02d:%02d.%03d" % [int( t/3600 ), int(int(t) % 3600 / 60), int(t) % 60, (t-int(t))*1000]
	%NumberButtonPressedTotal.text = "%d回" % [number_button_total_pressed_count]
	%EnterButtonPressedTotal.text = "%d回" % [enter_button_total_pressed_count]
	%BackButtonPressedTotal.text = "%d回" % [back_button_total_pressed_count]
	
	if number_button_total_pressed_count < 4:
		%BroIsCheater.show()
	else:
		%BroIsCheater.hide()
	
	return


func play_ending() -> void:
	$AnimationPlayer.play("game_ending")
	set_result_ui()
	$ResultLayer/Result.modulate = Color(0,0,0,0)
	$ResultLayer.show()
	await $AnimationPlayer.animation_finished
	%BackToTitleButton.disabled = false
	return


func refresh_password_display() -> void:
	%PasswordDisplayLabel.text = ""
	for x in current_input:
		if x == -1:
			break
		%PasswordDisplayLabel.text += var_to_str(x)
	return


func is_correct_password() -> bool:
	var res:int = 0
	for i in range(0, 4, 1):
		res += current_input[i] * pow(10, 3-i)
		pass
	print_debug("res: %d" % [res])
	return res == answer


func _on_kinko_button_pressed(my_number:int) -> void:
	
	if game_finished:
		return
	
	if my_number == 10:
		if number_button_pressed_counter != 0:
			number_button_pressed_counter -= 1
			current_input[number_button_pressed_counter] = -1
			refresh_password_display()
			pass
		back_button_total_pressed_count += 1
		$BackSound.play()
		return
	
	if my_number == 11:
		enter_button_total_pressed_count += 1
		if number_button_pressed_counter >= 4 && is_correct_password():
			game_finished = true
			$AnimationPlayer.play("password_correct")
			await $AnimationPlayer.animation_finished
			play_ending()
		else:
			$AnimationPlayer.play("password_incorrect")
			current_input = [-1, -1, -1, -1]
			number_button_pressed_counter = 0
			refresh_password_display()
		return
	
	if number_button_pressed_counter < 4:
		current_input[number_button_pressed_counter] = my_number
		number_button_pressed_counter += 1
		refresh_password_display()
		pass
	
	number_button_total_pressed_count += 1
	$NumberInputSound.play()
	
	return


func _on_back_to_title_button_pressed() -> void:
	get_parent().change_scene("title")
	return

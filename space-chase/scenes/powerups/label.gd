extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	# Clear the text first
	text = "Active Powerups:\n"
	text += str($"..".throw_strength)
	
	# Iterate through the active powerups to display their details
	for player_id in PowerupManager.active_powerups.keys():
		text += "Player %s:\n" % player_id
		for powerup_type in PowerupManager.active_powerups[player_id].keys():
			var powerup_data = PowerupManager.active_powerups[player_id][powerup_type]
			text += " - %s: Active=%s" % [powerup_type, powerup_data["active"]]
			if powerup_data.has("timer") and powerup_data["timer"].is_queued_for_deletion() == false:
				text += ", Time Left=%.2f\n" % powerup_data["timer"].time_left
			else:
				text += ", No Timer\n"

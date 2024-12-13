extends ProgressBar


func set_color(col: Color):
	get_theme_stylebox("fill").set("bg_color", col)

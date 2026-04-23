extends Label

const LIMIT := 0.1
var timer := 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer > LIMIT:
		timer = 0.0
		text = str(  "fps: "+ str(  Engine.get_frames_per_second() )  )

	if Engine.get_frames_per_second() <= 25.0:
		add_theme_color_override("font_color",Color(1, 0.1, 0))
		add_theme_font_size_override("font_size",18)
	elif  Engine.get_frames_per_second() <= 40:	
		add_theme_color_override("font_color",Color(0.863, 1, 0))
		add_theme_font_size_override("font_size",16)
	elif  Engine.get_frames_per_second() <= 60:
		add_theme_color_override("font_color",Color(0.05, 1, 0))
		add_theme_font_size_override("font_size",15)
	

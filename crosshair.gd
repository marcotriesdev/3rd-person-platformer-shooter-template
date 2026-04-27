extends Node2D

const aim_scale := Vector2(0.8,0.8)
const hip_scale := Vector2(2.5,2.5)
@onready var lines = [$Line2D,$Line2D2,$Line2D3,$Line2D4]
var colour = ColorPicker

const crosshair_speed := 0.2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		scale = lerp(scale,aim_scale,crosshair_speed)
		for line in lines:
			line.width = 2.0
			line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	else:
		scale = lerp(scale,hip_scale,crosshair_speed)
		for line in lines:
			line.width = 0.2		
			line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
			
			
	if get_tree().paused:
		visible = false
	else:
		visible = true

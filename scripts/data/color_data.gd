extends Resource
class_name ColorData

@export var description: String
@export var colors_1: GradientTexture2D
@export var colors_2: GradientTexture2D
@export var weigth: float


func _init() -> void:
    description = ""
    colors_1 = null
    colors_2 = null
    weigth = 1.0
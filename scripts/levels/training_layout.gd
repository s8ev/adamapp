class_name TrainingLayout
extends RefCounted

const CHECKPOINTS := [Vector2(80, 304), Vector2(1050, 304), Vector2(1640, 304), Vector2(2310, 304)]
const SOLIDS := [
	Rect2(-32, 0, 32, 480), Rect2(0, 304, 900, 176), Rect2(1020, 304, 1440, 176),
	Rect2(600, 238, 160, 46), Rect2(1260, 264, 54, 40), Rect2(1330, 205, 24, 99),
	Rect2(1420, 241, 64, 63), Rect2(1500, 185, 90, 12), Rect2(1890, 270, 60, 34),
	Rect2(2460, 0, 32, 480),
]


static func build(parent: Node2D) -> void:
	for rect in SOLIDS:
		var body := StaticBody2D.new()
		body.position = rect.position + rect.size / 2
		body.collision_layer = 1
		body.collision_mask = 0
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		body.add_child(collision)
		parent.add_child(body)


class_name ColorHelpers
extends RefCounted

enum ColorMode {
	DEFINED = 0,
	PALETTE = 1,
	RANDOM = 2,
}


static func generate_new_colors(count: int, rand_generator: RandomNumberGenerator) -> PackedColorArray:
	# Simple color palette generation based on https://iquilezles.org/articles/palettes/

	# Use planet rand generator for colors too for now.
	# It gives consistency between generations (seed remains the same)
	# but user cannot randomly generate colors
	var a: Vector3 = Vector3(0.5, 0.5, 0.5)
	var b: Vector3 = Vector3(0.5, 0.5, 0.5)
	var c: Vector3 = Vector3(
		rand_generator.randf_range(0.4, 1.5),
		rand_generator.randf_range(0.4, 1.5),
		rand_generator.randf_range(0.4, 1.5),
	)
	var d: Vector3 = Vector3(
		rand_generator.randf_range(0.4, 1.2),
		rand_generator.randf_range(0.4, 1.2),
		rand_generator.randf_range(0.4, 1.2),
	)

	var colors: PackedColorArray = PackedColorArray()

	count = max(count, 1)
	for i: int in range(0, count):
		var modif: float = i / max(count - 1.0, 1.0)
		var x: float = a.x + b.x * cos(6.28 * (c.x * modif + d.x))
		var y: float = a.y + b.y * cos(6.28 * (c.y * modif + d.y))
		var z: float = a.z + b.z * cos(6.28 * (c.z * modif + d.z))
		colors.append(Color(x, y, z))

	return colors

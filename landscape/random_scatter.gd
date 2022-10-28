extends MultiMeshInstance


func _ready():
	for idx in multimesh.instance_count:
		var transform = Transform(Basis.IDENTITY, Vector3.ZERO)
		transform = transform.scaled(Vector3.ONE * rand_range(0.35, 1.5))
		transform = transform.translated(Vector3(rand_range(-2000, 2000), 0, rand_range(-2000, 2000)))
		transform = transform.rotated(Vector3.UP, randf())
		multimesh.set_instance_transform(idx, transform)

extends MultiMeshInstance

var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = 0
	for idx in multimesh.instance_count:
		var transform = Transform(Basis.IDENTITY, Vector3.ZERO)
		transform = transform.scaled(Vector3.ONE * rng.randf_range(0.75, 2.0))
		transform = transform.translated(Vector3(rng.randf_range(-2000, 2000), 0, rng.randf_range(-2000, 2000)))
		transform = transform.rotated(Vector3.UP, rng.randf())
		multimesh.set_instance_transform(idx, transform)

extends MeshInstance

func _process(delta):
	rotate_object_local(Vector3.LEFT, delta * 100)

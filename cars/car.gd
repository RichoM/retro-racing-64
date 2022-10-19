extends MeshInstance

func _process(delta):
	rotate_object_local(Vector3.BACK, delta)

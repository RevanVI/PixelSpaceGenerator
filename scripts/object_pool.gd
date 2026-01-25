class_name ObjectPool
extends Node

enum ObjectPoolMode {
	CONST_SIZE = 0,
	GROWING_SIZE = 1,
}

var _objects: Array[Node] = []
var _object_status: Array[bool] = []
var _mode: ObjectPoolMode = ObjectPoolMode.CONST_SIZE
var _template: PackedScene


func init(object_template: PackedScene, count: int, mode: ObjectPoolMode = ObjectPoolMode.CONST_SIZE) -> void:
	_template = object_template
	_mode = mode
	for i: int in range(count):
		var object: Node = _template.instantiate()
		add_child(object)
		object.hide()
		object.set_process(false)
		_objects.append(object)
		_object_status.append(true)


func get_object() -> Node:
	for i: int in range(_objects.size()):
		if _object_status[i] == true:
			_object_status[i] = false
			_objects[i].set_process(true)
			return _objects[i]

	if (_mode == ObjectPoolMode.GROWING_SIZE):
		var object: Node = _template.instantiate()
		add_child(object)
		object.hide()
		_objects.append(object)
		_object_status.append(false)
		return object

	Log.error(self, "No free objects in pool")
	return null


func return_object(object: Node) -> void:
	var index: int = _objects.find(object)
	if index != -1:
		object.hide()
		object.set_process(false)
		_object_status[index] = true


func get_used_objects() -> Array[Node]:
	var used_objects: Array[Node] = []
	for i: int in range(_objects.size()):
		if _object_status[i] == false:
			used_objects.append(_objects[i])
	return used_objects

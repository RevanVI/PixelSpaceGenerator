extends CanvasLayer

signal debug_container_registered

var _show_debug_interface: bool = false
var _debug_containers: Dictionary = { }
var _debug_container: DebugContainer

@onready var debug_tabs: TabBar = $UiContainer/VBoxContainer/DebugTabs
@onready var debug_content_container: MarginContainer = $UiContainer/VBoxContainer/DebugContentContainer
@onready var _ui_container: Control = $UiContainer


func _ready() -> void:
	set_ui_container_visibility(_show_debug_interface)
	debug_tabs.tab_changed.connect(_on_tab_changed)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('toggle_debug_interface'):
		_show_debug_interface = !_show_debug_interface
		set_ui_container_visibility(_show_debug_interface)


func update_widget(widget_path: String, data = null) -> void:
	var split_keyword: PackedStringArray = widget_path.split(":")
	if split_keyword.size() == 1:
		Log.error(name, "No container name was provided: " + widget_path)
		return

	var container_name: String = split_keyword[0]
	if not _debug_containers.has(container_name):
		Log.error(name, "Container " + container_name + " is not registered")
		return

	var container_node: DebugContainer = _debug_containers[container_name]
	widget_path = split_keyword[1]
	container_node.update_widget(widget_path, data)


func register_debug_container(container_node: DebugContainer) -> void:
	var container_name: String = container_node.name
	if _debug_containers.has(container_name):
		Log.error(name, "DebugContainer " + container_name + " has been already registered")
		return
	container_node.get_parent().call_deferred("remove_child", container_node)
	debug_content_container.call_deferred("add_child", container_node)
	_debug_containers[container_name] = container_node
	if _debug_containers.size() == 1:
		_debug_container = container_node
	container_node.hide()
	debug_tabs.add_tab(container_name)
	debug_container_registered.emit(container_node)


func set_ui_container_visibility(value: bool) -> void:
	_ui_container.visible = value


func is_container_registered(widget_path: String) -> bool:
	var split_keyword: PackedStringArray = widget_path.split(":")
	if split_keyword.size() == 1:
		return false

	var container_name: String = split_keyword[0]
	if not _debug_containers.has(container_name):
		return false

	return true


func _on_tab_changed(tab_index: int) -> void:
	var tab_name: String = debug_tabs.get_tab_title(tab_index)
	var container_node: DebugContainer = _debug_containers[tab_name]
	_debug_container.hide()
	_debug_container = container_node
	_debug_container.show()

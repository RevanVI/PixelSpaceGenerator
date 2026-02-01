extends Node2D

var test_ct: int = -1


func _process(_delta) -> void:
	test_ct += 1
	if test_ct >= 1000:
		test_ct = -1
	elif test_ct == 900:
		Debug.update_widget('TestDebugContainer:TextList1.remove_label', { 'name': 'counter' })
		Debug.update_widget('TestDebugContainer2:TextList1.remove_label', { 'name': 'counter' })
	elif test_ct < 900:
		Debug.update_widget('TestDebugContainer:TextList1.add_label', { 'name': 'counter', 'value': str(test_ct % 1000) })
		Debug.update_widget('TestDebugContainer2:TextList1.add_label', { 'name': 'counter', 'value': str(round(test_ct / 10.0)) })

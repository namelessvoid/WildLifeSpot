extends Node
class_name DatabaseManagerSQLite

var _db_path = &"user://wildlifespot.db"

func set_db_path(p_db_path: String):
	_db_path = p_db_path

	var global_db_path = ProjectSettings.globalize_path(p_db_path)
	var injectable_nodes: Array[Node] = get_tree().get_nodes_in_group("inject_db_path")
	for node in injectable_nodes:
		if node.has_method("set_db_path"):
			node.set_db_path(_db_path)
		else:
			node.SetDbPath(global_db_path)

	GlobalSignals.database_changed.emit()

func _ready():
	set_db_path(_db_path)

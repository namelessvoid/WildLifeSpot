using Godot;
using WildLifeSpot.Infrastructure;

[GlobalClass]
public partial class DatabaseManagerSQLite : Node
{
    private StringName _dbPath = new("user://wildlifespot.db");



    public void SetDbPath(StringName dbPath)
    {
        _dbPath = dbPath;

        var globalDbPath = ProjectSettings.GlobalizePath(_dbPath);

        using (var context = new WildlifeSpotDbContext(globalDbPath))
        {
            GD.Print("Ensure tables created");
            context.Database.EnsureCreated();
        }

        var injectableNodes = GetTree().GetNodesInGroup("inject_db_path");
        foreach (var node in injectableNodes)
        {
            if (node.HasMethod("set_db_path"))
            {
                node.Call("set_db_path", _dbPath);
            }
            else
            {
                node.Call("SetDbPath", globalDbPath);
            }
        }

        var globalSignals = GetTree().Root.GetNode("/root/GlobalSignals");
        globalSignals.EmitSignal("database_changed");
    }

    public override void _Ready()
    {
        base._Ready();
        SQLitePCL.raw.SetProvider(new SQLitePCL.SQLite3Provider_e_sqlite3());
        SetDbPath(_dbPath);
    }
}



// extends Node
// class_name DatabaseManagerSQLite
//
// var _db_path = &"user://wildlifespot.db"
//
// func set_db_path(p_db_path: String):
// 	_db_path = p_db_path
//
// 	var global_db_path = ProjectSettings.globalize_path(p_db_path)
// 	var injectable_nodes: Array[Node] = get_tree().get_nodes_in_group("inject_db_path")
// 	for node in injectable_nodes:
// 		if node.has_method("set_db_path"):
// 			node.set_db_path(_db_path)
// 		else:
// 			node.SetDbPath(global_db_path)
//
// 	GlobalSignals.database_changed.emit()
//
// func _ready():
// 	set_db_path(_db_path)

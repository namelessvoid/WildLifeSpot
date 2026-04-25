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
        SetProvider();
        SetDbPath(_dbPath);
    }

    private void SetProvider()
    {
        SQLitePCL.raw.SetProvider(new SQLitePCL.SQLite3Provider_e_sqlite3());
    }
}

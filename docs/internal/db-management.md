# Database Management

WildLifeSpot uses SQLite to store data. Repository and EFCore DBContext abstractions are used to access the data. Since WildLifeSpot allows to have multiple separate databases, the `DatabaseManagerSqlite` is responsible for updating the selected database path in repositories / handlers and to emit the global `database_changed` signal.

Controls, that have to refresh when the database is changed, should connect to the `GlobalSignals.database_changed` signal.

## Auto-inject database path

Nodes, that need the database path, can be assigned to the `inject_db_path` group. When the database path changes, these nodes are queried by the database manager. The manager then invokes the `set_db_path(...)` (GDScript) or `SetDbPath(...)` (C#) method on each node. For GDScript, the "local" file path (e.g. "user://wildlifespot.db") is provided. C# methods receive the globalized path (see [ProjectSettings.globalize_path()](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html#class-projectsettings-method-globalize-path)).

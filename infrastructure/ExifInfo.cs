using Godot;

[GlobalClass]
public partial class ExifInfo : RefCounted
{
    public string DateTime { get; set; }

    public string CameraMake { get; set; }
}
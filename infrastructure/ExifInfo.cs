using Godot;
using System;

[GlobalClass]
public partial class ExifInfo : RefCounted
{
	public string DateTime { get; set; }
	
	public string CameraMake { get; set; }
}

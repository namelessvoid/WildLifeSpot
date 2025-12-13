using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Godot;
using Godot.Collections;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class AnimalSpot : RefCounted
{
    public static string SourceCameraImage() => "CAMERA_IMAGE";

    public static string SourceHumanSeen() => "HUMAN_SEEN";
    public static string SourceHumanHeard() => "HUMAN_HEARD";
    
    public static Array<string> Sources() =>
    [
        SourceCameraImage(),
        SourceHumanSeen(),
        SourceHumanHeard()
    ];
    
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; private set; }
    public string Source { get; set; }
    public string FilePath { get; set; }
    public int CameraId { get; set; }

    public string SpottedAt
    {
        get => SpottedAtDateTime.ToString("s");
        set => SpottedAtDateTime = DateTime.Parse(value);
    }

    public DateTime SpottedAtDateTime { get; set; }
    public string AnimalName { get; set; }
    public int AnimalCount { get; set; }
    public override string ToString()
    {
        return $"AnimalSpot(Id={Id}, SpottedAt={SpottedAt}, Source={Source}, AnimalName={AnimalName}, AnimalCount{AnimalCount})";
    }
}
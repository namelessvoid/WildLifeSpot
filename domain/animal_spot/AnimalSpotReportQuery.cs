using Godot;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class AnimalSpotReportQuery : RefCounted
{
    public ReportOptions ReportOptions { get; private set; } = new();
}

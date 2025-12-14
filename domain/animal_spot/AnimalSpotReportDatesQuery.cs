using Godot;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class AnimalSpotReportDatesQuery : RefCounted
{
    public ReportOptions ReportOptions { get; private set; } = new();
}

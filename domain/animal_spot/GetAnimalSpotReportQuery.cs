using Godot;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class GetAnimalSpotReportQuery : RefCounted
{
    public ReportOptions ReportOptions { get; private set; } = new();
}

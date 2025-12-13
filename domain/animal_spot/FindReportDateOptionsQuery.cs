using Godot;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class FindReportDateOptionsQuery : RefCounted
{
    public ReportOptions ReportOptions { get; private set; } = new();
}

using Godot;
using Godot.Collections;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class ReportOptions : RefCounted
{
    public static string GranularityHourly() => "GRANULARITY_HOURLY";

    public static string GranularityDaily() => "GRANULARITY_DAILY";

    public static string GranularityMonthly() => "GRANULARITY_MONTHLY";

    public static Array<string> Granularities() =>
    [
        GranularityHourly(),
        GranularityDaily(),
        GranularityMonthly()
    ];

    private string _granularity = GranularityHourly();

    public string Granularity
    {
        get => _granularity;
        set
        {
            if (!Granularities().Contains(value))
            {
                GD.PushError($"Provided granularity '{value}' is not supported.");
                return;
            }

            _granularity = value;
        }
    }

    public string DateFilter { get; set; }
}

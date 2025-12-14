using Godot;
using Godot.Collections;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class ReportOptions : RefCounted
{
    public const string GranularityHourly = "GRANULARITY_HOURLY";
    public const string GranularityDaily = "GRANULARITY_DAILY";
    public const string GranularityMonthly = "GRANULARITY_MONTHLY";

    public static string GetGranularityHourly() => GranularityHourly;

    public static string GetGranularityDaily() => GranularityDaily;

    public static string GetGranularityMonthly() => GranularityMonthly;

    public static Array<string> GetGranularities() =>
    [
        GranularityHourly,
        GranularityDaily,
        GranularityMonthly
    ];

    private string _granularity = GranularityHourly;

    public string Granularity
    {
        get => _granularity;
        set
        {
            if (!GetGranularities().Contains(value))
            {
                GD.PushError($"Provided granularity '{value}' is not supported.");
                return;
            }

            _granularity = value;
        }
    }

    public string DateFilter { get; set; }
}

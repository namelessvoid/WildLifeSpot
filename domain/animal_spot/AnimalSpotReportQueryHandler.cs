using System;
using System.Linq;
using System.Linq.Expressions;
using Godot;
using Godot.Collections;
using WildLifeSpot.Infrastructure;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class AnimalSpotReportQueryHandler: Node
{
    private WildlifeSpotDbContext _context;

    public override void _EnterTree()
    {
        base._EnterTree();
        AddToGroup("command_query_handler");
        AddToGroup("inject_db_path");
    }

    public void SetDbPath(string dbPath)
    {
        _context?.Dispose();
        _context = new WildlifeSpotDbContext(dbPath);
    }

    public bool CanHandle(Variant dispatchable)
    {
        return dispatchable.Obj is AnimalSpotReportQuery;
    }

    public Variant Handle(Variant dispatchable)
    {
        return dispatchable.Obj switch
        {
            AnimalSpotReportQuery query => GetAnimalSpotReport(query),
            _ => new Variant()
        };
    }

    private Variant GetAnimalSpotReport(AnimalSpotReportQuery query)
    {
        var granularity = query.ReportOptions.Granularity;

        if (!ReportOptions.GetGranularities().Contains(granularity))
        {
            GD.PushError($"Invalid granularity: '{granularity}'");
            return new Variant();
        }

        var dateFilter = query.ReportOptions.DateFilter;
        DateOnly.TryParse(dateFilter, out var filterDate);
        Expression<Func<AnimalSpot, bool>> dateFilterPredicate = granularity switch
        {
            ReportOptions.GranularityHourly => spot => spot.SpottedAtDateTime.Date == DateTime.Parse(dateFilter),
            ReportOptions.GranularityDaily => spot => spot.SpottedAtDateTime.Year == filterDate.Year && spot.SpottedAtDateTime.Month == filterDate.Month,
            ReportOptions.GranularityMonthly => spot => spot.SpottedAtDateTime.Year == int.Parse(dateFilter)
        };

        Expression<Func<AnimalSpot, AnimalTimeGroupKey>> groupBy = granularity switch
        {
            ReportOptions.GranularityHourly => spot => new AnimalTimeGroupKey(
                spot.SpottedAtDateTime.Hour,
                spot.AnimalName
            ),
            ReportOptions.GranularityDaily => spot => new AnimalTimeGroupKey(
                spot.SpottedAtDateTime.Day,
                spot.AnimalName
            ),
            ReportOptions.GranularityMonthly => spot => new AnimalTimeGroupKey(
                spot.SpottedAtDateTime.Month,
                spot.AnimalName
            ),
        };

        var animalHourCountRows = _context.AnimalSpots
            .Where(dateFilterPredicate)
            .GroupBy(
            groupBy,
            spot => spot.AnimalCount,
            (group, count) => new
            {
                group.TimeSlot,
                group.AnimalName,
                Count = count.Max()
            }
        ).ToList();

        int timeSlots = granularity switch
        {
            ReportOptions.GranularityHourly => 24,
            ReportOptions.GranularityDaily => 31,
            ReportOptions.GranularityMonthly => 12
        };

        var countsPerAnimal = new Dictionary<string, Array<int>>();
        foreach (var animalHourlyCounts in animalHourCountRows)
        {
            var animalName = animalHourlyCounts.AnimalName;
            var hour = animalHourlyCounts.TimeSlot;
            var count = animalHourlyCounts.Count;

            if (!countsPerAnimal.ContainsKey(animalName))
            {
                var emptyTimeSlots = new Array<int>();
                emptyTimeSlots.Resize(timeSlots);
                emptyTimeSlots.Fill(0);
                countsPerAnimal.Add(animalName, emptyTimeSlots);
            }

            countsPerAnimal[animalName][hour] = count;
        }

        var maxCount = animalHourCountRows.Max(c => c.Count);
        Func<int, string> labelFunction = granularity switch
        {
            ReportOptions.GranularityHourly => i => $"{i} - {i+1}h",
            ReportOptions.GranularityDaily => i => $"{(i+1).ToString().PadLeft(2, '0')}",
            ReportOptions.GranularityMonthly => i => $"{dateFilter}-{(i+1).ToString().PadLeft(2, '0')}"
        };

        Array<string> xLabels = new Array<string>(Enumerable
            .Range(0, timeSlots)
            .Select(labelFunction)
            .ToList()
        );

        var report = new AnimalSpotReport(
            maxCount: maxCount,
            xLabels: xLabels,
            countsPerAnimal: countsPerAnimal
        );

        return Variant.From(report);
    }

    private record struct AnimalTimeGroupKey(int TimeSlot, string AnimalName);
}

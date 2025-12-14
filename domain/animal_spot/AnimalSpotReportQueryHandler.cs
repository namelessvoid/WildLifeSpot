using System;
using System.Linq;
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
        var animalHourCountRows = _context.AnimalSpots.Where(spot =>
            spot.SpottedAtDateTime.Date == DateTime.Parse(query.ReportOptions.DateFilter)
        ).GroupBy(
            spot => new { spot.SpottedAtDateTime.Hour, spot.AnimalName },
            spot => spot.AnimalCount,
            (group, count) => new
            {
                group.Hour,
                group.AnimalName,
                Count = count.Max()
            }
        ).ToList();

        const int timeSlots = 24;
        var countsPerAnimal = new Dictionary<string, Array<int>>();
        foreach (var animalHourlyCounts in animalHourCountRows)
        {
            var animalName = animalHourlyCounts.AnimalName;
            var hour = animalHourlyCounts.Hour;
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
        var xLabels = new Array<string>(Enumerable
            .Range(0, timeSlots)
            .Select(i => $"{i} - {i+1}h")
            .ToList()
        );
        var report = new AnimalSpotReport(
            maxCount: maxCount,
            xLabels: xLabels,
            countsPerAnimal: countsPerAnimal
        );

        return Variant.From(report);
    }
}

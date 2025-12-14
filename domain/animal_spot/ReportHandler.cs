using System;
using System.Linq;
using Godot;
using Godot.Collections;
using WildLifeSpot.Infrastructure;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class ReportHandler: Node
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
        return dispatchable.Obj
            is FindReportDateOptionsQuery
            or GetAnimalSpotReportQuery;
    }

    public Variant Handle(Variant dispatchable)
    {
        return dispatchable.Obj switch
        {
            FindReportDateOptionsQuery query => FindReportDateOptions(query),
            GetAnimalSpotReportQuery query => GetAnimalSpotReport(query),
            _ => new Variant()
        };
    }

    // Method determines the available date options for a given query.
    // Note: It shifts granularity by "one", means: A query for daily
    // granularity will return a list of year-months. A query for
    // hours will return a list of year-month-days.
    private Variant FindReportDateOptions(FindReportDateOptionsQuery query)
    {
        var reportOptions = query.ReportOptions;

        var spots = _context.AnimalSpots;
        IQueryable<string> dateOptions;

        if (reportOptions.Granularity == ReportOptions.GranularityHourly())
        {
            dateOptions = spots.Select(spot =>
                DateOnly.FromDateTime(spot.SpottedAtDateTime).ToString("o")
            );
        }
        else if(reportOptions.Granularity == ReportOptions.GranularityDaily())
        {
            dateOptions = spots.Select(spot =>
                    new { spot.SpottedAtDateTime.Year, spot.SpottedAtDateTime.Month }
                )
                .Select(t =>
                    new DateOnly(t.Year, t.Month, 1).ToString("yyyy-MM")
                );
        }
        else
        {
            dateOptions = spots.Select(spot => spot.SpottedAtDateTime.Year.ToString());
        }

        dateOptions = dateOptions.Distinct();

        var result = new Array<string>(
            dateOptions.ToList()
        );
        return Variant.CreateFrom(result);
    }

    public Variant GetAnimalSpotReport(GetAnimalSpotReportQuery query)
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

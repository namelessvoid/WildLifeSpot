using System;
using System.Linq;
using Godot;
using Godot.Collections;
using WildLifeSpot.Infrastructure;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class AnimalSpotReportDatesQueryHandler : Node
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
        return dispatchable.Obj is AnimalSpotReportDatesQuery;
    }

    public Variant Handle(Variant dispatchable)
    {
        return dispatchable.Obj switch
        {
            AnimalSpotReportDatesQuery query => FindReportDateOptions(query),
            _ => new Variant()
        };
    }

    // Method determines the available date options for a given query.
    // Note: It shifts granularity by "one", means: A query for daily
    // granularity will return a list of year-months. A query for
    // hours will return a list of year-month-days.
    private Variant FindReportDateOptions(AnimalSpotReportDatesQuery query)
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
}

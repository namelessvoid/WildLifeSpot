using System;
using System.Linq;
using Godot;
using Godot.Collections;
using Microsoft.EntityFrameworkCore;
using WildLifeSpot.AnimalSpots.Domain;

namespace WildLifeSpot.Infrastructure;

[GlobalClass]
public partial class AnimalRepository : Node
{
    private WildlifeSpotDbContext context;

    public override void _ExitTree()
    {
        base._ExitTree();
        if (context != null)
        {
            GD.Print("DISPOSING CONTEX");
            context.Dispose();
            context = null;
        }
    }

    public void SetDbPath(string dbPath)
    {
        context?.Dispose();
        context = new WildlifeSpotDbContext(dbPath);
        context.Database.EnsureCreated();
    }

    public void Save(AnimalSpot animalSpot)
    {
        context.AnimalSpots.Add(animalSpot);
        context.SaveChanges();
    }

    public Array<AnimalSpot> FindAll()
    {
        return new Array<AnimalSpot>(context.AnimalSpots.ToList());
    }

    public Array<AnimalSpot> FindAllBy(string source, long cameraId, string spottedAt)
    {
        return new Array<AnimalSpot>(
            context.AnimalSpots.Where(spot =>
                spot.Source == source && spot.CameraId == cameraId && spot.SpottedAt == spottedAt
            ).ToList()
        );
    }

    public Array<AnimalSpot> FindAllByDate(string spottedAt)
    {
        return new Array<AnimalSpot>(
            context.AnimalSpots.Where(spot => spot.SpottedAt == spottedAt).ToList()    
        );
    }

    public Array<string> FindAllDates()
    {
        return new Array<string>(
            context.AnimalSpots.Select(spot => spot.SpottedAtDateTime.Date.ToString("o")).Distinct().ToList()
        );
    }

    public Array<string> FindAllDistinctAnimalNames()
    {
        return new Array<string>(
            context.AnimalSpots.Select(spot => spot.AnimalName).Distinct().ToList()
        );
    }

    public void DeleteBySourceAndSpottedAt(string source, string spottedAtString)
    {
        var spottedAt = DateTime.Parse(spottedAtString);
        context.AnimalSpots.Where(spot => spot.Source == source && spot.SpottedAtDateTime == spottedAt).ExecuteDelete();
    }
}
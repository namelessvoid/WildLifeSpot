using System;
using System.Data.Common;
using Godot;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WildLifeSpot.AnimalSpots.Domain;

namespace WildLifeSpot.Infrastructure;

public class WildlifeSpotDbContext(string dbPath) : DbContext
{
    public DbSet<AnimalSpot> AnimalSpots { get; set; }

    public string DbPath { get; } = dbPath;

    protected override void OnModelCreating(ModelBuilder builder)
    {
        builder.Entity<AnimalSpot>(entity =>
        {
            entity.ToTable("animal_spot")
                .Ignore(a => a.SpottedAt);
            entity.Property(a => a.Id).HasColumnName("id");
            entity.Property(a => a.Source).HasColumnName("source");
            entity.Property(a => a.FilePath).HasColumnName("file_path");
            entity.Property(a => a.CameraId).HasColumnName("camera_id");
            entity.Property(a => a.SpottedAtDateTime).HasColumnName("spotted_at").HasConversion<string>();
            entity.Property(a => a.AnimalName).HasColumnName("animal_name");
            entity.Property(a => a.AnimalCount).HasColumnName("animal_count");
        });
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        var connectionStringBuilder = new SqliteConnectionStringBuilder
        {
            DataSource = DbPath
        };

        var connectionString = connectionStringBuilder.ToString();
        GD.Print(connectionString);
        optionsBuilder.UseSqlite(connectionString)
            .LogTo(GD.Print, LogLevel.Information);
    }
}
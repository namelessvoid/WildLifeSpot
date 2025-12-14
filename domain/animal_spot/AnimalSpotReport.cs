using Godot;
using Godot.Collections;

namespace WildLifeSpot.AnimalSpots.Domain;

[GlobalClass]
public partial class AnimalSpotReport(
    int maxCount,
    Array<string> xLabels,
    Dictionary<string, Array<int>> countsPerAnimal
) : RefCounted
{
    public int MaxCount { get; private set; } = maxCount;

    public Dictionary<string, Array<int>> CountsPerAnimal { get; private set; } = countsPerAnimal;

    public Array<string> XLabels { get; private set; } = xLabels;
}

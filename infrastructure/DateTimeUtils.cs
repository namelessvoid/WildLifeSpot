using Godot;
using System;
using System.Globalization;

[GlobalClass]
public partial class DateTimeUtils : RefCounted
{
    public static bool IsValidDate(string dateString)
    {
        DateOnly parsed;
        return DateOnly.TryParse(dateString, out parsed);
    }

    public static string ParseDate(string dateString)
    {
        return DateOnly.Parse(dateString).ToString("o", CultureInfo.InvariantCulture);
    }

    public static bool IsValidTime(string timeString)
    {
        TimeOnly parsed;
        return TimeOnly.TryParse(timeString, out parsed);
    }

    public static string ParseTime(string timeString)
    {
        return TimeOnly.Parse(timeString).ToString("HH:mm:ss", CultureInfo.InvariantCulture);
    }
}

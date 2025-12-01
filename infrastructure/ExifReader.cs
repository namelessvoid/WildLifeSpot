using Godot;
using System;
using System.Collections.Generic;
using MetadataExtractor;
using MetadataExtractor.Formats.Exif;

[GlobalClass]
public partial class ExifReader : Node
{
	public Godot.Collections.Dictionary<string, ExifInfo> GetExifInfo(string[] filePaths)
	{
		var exifInfos = new Godot.Collections.Dictionary<string, ExifInfo>();
		
		foreach(var filePath in filePaths)
		{
			var directories = ImageMetadataReader.ReadMetadata(filePath);
			
			var exifInfo = new ExifInfo();
			exifInfo.CameraMake = FindCameraMake(directories);;
			exifInfo.DateTime = FindDateTime(directories);;
			
			exifInfos[filePath] = exifInfo;
		}
		
		return exifInfos;
	}

	private string FindCameraMake(IReadOnlyList<Directory> directories)
	{
		foreach(var directory in directories)
		{
			if(directory is ExifIfd0Directory)
			{
				return directory.GetDescription(ExifDirectoryBase.TagMake);
			}
		}
		return string.Empty;
	}

	private string FindDateTime(IReadOnlyList<Directory> directories)
	{
		foreach(var directory in directories)
		{
			if(directory is ExifIfd0Directory)
			{
				var rawValue = directory.GetDescription(ExifDirectoryBase.TagDateTime);
				if(string.IsNullOrEmpty(rawValue))
				{
					return string.Empty;
				}

				var parts = rawValue.Split(" ");
				var date = parts[0].Replace(":", "-");
				var time = parts[1];
				return date + "T" + time;
			}
		}
		return string.Empty;
	}
}

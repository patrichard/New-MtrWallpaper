# New-MtrWallpaper

Configure a new wallpaper for Microsoft Teams Room (MTR) System

## Description

Wallpaper is then copied to the proper folder, and a corresponding XML file is also written.

When the system reboots as part of its normal scheduled nightly maintenance, the new wallpaper is set for the 'Custom' them in MTR.

## Notes

None for now. May play with configuring a list of dates and corresponding wallpaper images (*think holiday wallpapers*).

All Images _must_ be exactly 3840×1080, for Single or dual screen MTR systems!!!

If you copy the wallpaper image (wallpaper.jpg), with or without the settings XML, to different MTR systems the change will not be activated!
The MTR doesn't do a reload or check if a file is changed.
The MTR will reboot every day at 2:30 (AM), then the changes will be activated.

The MTR support .jpg, .jpeg, .png, and .bmp for wallpapers. Since version 1.0.1 of `New-MtrWallpaper` we support them all.

It's just a minor changed version based on the great work of Pat Richard.

### Changelog

1.0.3 Add more parmeters (e.g. check resolution, and Template coloring)
1.0.2 Add the Check (resolution) helper function: `Test-MtrWallpaper`
1.0.1 Add support for all supported wallpaper Types (based on extensions)
1.0.0 Fork from [Pat Richard](https://github.com/patrichard/New-MtrWallpaper)'s `New-MtrWallpaper`

## Original Author

[Pat Richard](https://github.com/patrichard/New-MtrWallpaper)

## License

Ask [Pat Richard](https://github.com/patrichard/New-MtrWallpaper) :-)

As soon as Pat uploads a valid license to the repo, I will adopt it here.

## Origial Readme

This script, when run on a Microsoft Teams Room (MTR) System, will configure a new, randomly selected wallpaper, each day. The script pics the wallpaper from a folder, copies it to the appropriate folder, then writes a SkypeSettings.xml file that contains the relevant configuration info. MTRs have a built in process that includes a daily reboot. New-MtrWallpaper.ps1 leverages that reboot to enable the new wallpaper.
You can manually run the code in Create-MtrWallpaperScheduledTask.ps1 to create the actual scheduled task if desired.
Please see the article at https://www.ucunleashed.com/4323 for information on this script.

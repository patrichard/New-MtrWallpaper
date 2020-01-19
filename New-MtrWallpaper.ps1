function New-MtrWallpaper {
  <#
      .SYNOPSIS
      Configure a new wallpaper for Microsoft Teams Room (MTR) System

      .DESCRIPTION
      Configure a new wallpaper for Microsoft Teams Room (MTR) System. This is done by randomly choosing a .jpg file from a folder of images. Wallpaper is then copied to the proper folder, and a corresponding XML file is also written. When the system reboots as part of its normal scheduled nightly maintenance, the new wallpaper is set for the 'Custom' them in MTR.

      .EXAMPLE
      New-MtrWallpaper
      Picks image, copies to folder, and writes XML file

      .NOTES
      None for now. May play with configuring a list of dates and corresponding wallpaper images (think holiday wallpapers).

      .LINK
      https://www.ucunleashed.com/4323

      .INPUTS
      None. This function does not support pipeline input.

      .OUTPUTS
      None.
  #>
  [CmdletBinding(SupportsShouldProcess)]
  Param (
    [string] $ThisRoot = 'C:\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState'
  )
  # Let's clean up any remaining files (which shouldn't exist if last reboot successfully ingested the files)
  if (Get-Item -Path "$ThisRoot\wallpaper.jpg" -ErrorAction SilentlyContinue){Remove-Item -Path "$ThisRoot\wallpaper.jpg" -Force -Confirm:$false}
  if (Get-Item -Path "$ThisRoot\SkypeSettings.xml" -ErrorAction SilentlyContinue){Remove-Item -Path "$ThisRoot\SkypeSettings.xml" -Force -Confirm:$false}
  # Get a list of all of the wallpapers to choose from. Wallpaper images MUST be exactly 3840x1080, regardless if the MTR is a single or dual screen system.
  $AllWallpapers = (Get-ChildItem -Path "$ThisRoot\Wallpapers" -Filter *.jpg | Select-Object -Property Name)
  # Pick a random wallpaper - keep in mind that the fewer images to choose from, the higher the potential to choose the same image that was used last time.
  [string] $NewWallpaper = (Get-Random -InputObject $AllWallpapers).Name
  Write-Verbose -Message "Chosen wallpaper is $ThisRoot\Wallpapers\$NewWallpaper"
  if ($NewWallpaper) {
    # Copy the chosen wallpaper to the right folder. We rename it to a generic name as a safeguard against improper characters or file names that are too long.
    Copy-Item -Path "$ThisRoot\Wallpapers\$NewWallpaper" -Destination "$ThisRoot\wallpaper.jpg"
    # Create the new SkypeSettings.xml using only the fields we need to populate to configure the new wallpaper
    $xmlWriter = New-Object -TypeName System.XMl.XmlTextWriter -ArgumentList ("$ThisRoot\SkypeSettings.xml",$Null)
    $xmlWriter.Formatting = 'Indented'
    $xmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"
    $xmlWriter.WriteStartDocument()
    $xmlWriter.WriteStartElement('SkypeSettings')
    $xmlWriter.WriteStartElement('Theming')
    $xmlWriter.WriteElementString('ThemeName', 'Custom')
    $xmlWriter.WriteElementString('CustomThemeImageUrl','wallpaper.jpg')
    $xmlWriter.WriteStartElement('CustomThemeColor')
    $xmlWriter.WriteElementString('RedComponent','100')
    $xmlWriter.WriteElementString('GreenComponent','100')
    $xmlWriter.WriteElementString('BlueComponent','100')
    $xmlWriter.WriteEndElement() # CustomThemeColor
    $xmlWriter.WriteEndElement() # Theming
    $xmlWriter.WriteEndElement() # SkypeSettings
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()  
  }
}

New-MtrWallpaper

function New-MtrWallpaper
{
   <#
         .SYNOPSIS
         Configure a new wallpaper for Microsoft Teams Room (MTR) System

         .DESCRIPTION
         Configure a new wallpaper for Microsoft Teams Room (MTR) System.

         This is done by randomly choosing a supported image file from a folder.

         Wallpaper is then copied to the proper folder, and a corresponding XML file is also written.

         When the system reboots as part of its normal scheduled nightly maintenance,
         the new wallpaper is set for the 'Custom' them in MTR.

         .PARAMETER Path
         Local MTR User root path, as for now this is the same on every MTR device!
         Can be a Share (\\<MTRHostname>\\C$\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState),
         if you have more then one MTR or want to do it remotely!

         .PARAMETER Check
         Check if a given Wallpaperfile has the correct resolution

         .PARAMETER RedComponent
         RedComponent for the template
         Default is 100

         .PARAMETER GreenComponent
         GreenComponent for the template
         Default is 100

         .PARAMETER BlueComponent
         BlueComponent for the template
         Default is 100

         .EXAMPLE
         New-MtrWallpaper

         Picks a random image, copies to the root folder, and writes XML file

         .NOTES
         None for now. May play with configuring a list of dates and corresponding wallpaper images (think holiday wallpapers).

         All Images must be exactly 3840×1080, for Single or dual screen!

         If you copy the wallpaper image (wallpaper.jpg), with or without the settings XML,
         to different MTR systems the change will not be activated!
         The MTR doesn't do a reload or check if a file is changed.
         The MTR will reboot every day at 2:30 (AM), then the changes will be activated.

         The MTR support .jpg, .jpeg, .png, and .bmp for wallpapers!

         My version of the script has no enhancements, at least not yet!
         It's just a minor changed version based on the great work of Pat Richard.

         .LINK
         https://www.ucunleashed.com/4323

         .LINK
         https://github.com/patrichard/New-MtrWallpaper

         .LINK
         https://docs.microsoft.com/en-us/MicrosoftTeams/downloads/ThemingTemplateMicrosoftTeamsRooms_v2.1.psd

         .LINK
         https://www.ucit.blog/post/configuring-custom-themes-for-microsoft-teams-skype-room-systems

         .LINK
         https://www.bing.com/images/search?q=wallpaper+3840x1080&qpvt=wallpaper+3840x1080&form=IGRE&first=1&cw=1680&ch=939
   #>

   [CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('ThisRoot')]
      [string]
      $Path = "$env:HOMEDRIVE\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState",
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [switch]
      $Check,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateRange(0, 100)]
      [Alias('Red')]
      [int]
      $RedComponent = 100,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateRange(0, 100)]
      [Alias('Green')]
      [int]
      $GreenComponent = 100,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateRange(0, 100)]
      [Alias('Blue')]
      [int]
      $BlueComponent = 100
   )

   begin
   {
      #region Defaults
      $STP = 'Stop'
      $CNT = 'Continue'
      $SCT = 'SilentlyContinue'
      #endregion Defaults

      #region Helpers
      function Test-MtrWallpaper
      {
         <#
               .SYNOPSIS
               Check if a given Wallpaperfile has the correct resolution

               .DESCRIPTION
               Check if a given Wallpaperfile has the correct resolution.
               All Images must be exactly 3840×1080, for Single or dual screen!

               .PARAMETER Path
               Wallpaperfile to check (Full path)

               .INPUTS
               String

               .OUTPUTS
               Bool

               .EXAMPLE
               PS C:\> Test-MtrWallpaper -Path 'Z:\Desktop\wallpaper\TheBeachView.jpg'

               True

               .EXAMPLE
               PS C:\> Test-MtrWallpaper -Path 'Z:\Desktop\wallpaper\TheBeachView.jpg'

               False

               .NOTES
               All Images must be exactly 3840×1080, for Single or dual screen!
         #>
         [CmdletBinding(ConfirmImpact = 'None')]
         [OutputType([bool])]
         param
         (
            [Parameter(Mandatory, HelpMessage = 'Wallpaperfile to check (Full path)',
                  ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('Wallpaper', 'MTRWallpaper', 'Image')]
            [string]
            $Path
         )

         begin
         {
            # Cleanup
            $Check = $null

            # Load the Assembly
            $null = (Add-Type -AssemblyName System.Drawing)
         }

         process
         {
            # Creat the new variable with the Image (Assembly needed)
            $image = [Drawing.Image]::FromFile($Path)

            # Do the check
            if (($image.Width -eq '3840') -and ($image.Height -eq '1080'))
            {
               [bool]$Check = $true
            }
            else
            {
               [bool]$Check = $false
            }
         }

         end
         {
            return $Check
         }
      }
      #endregion Helpers

      #region Check
      try
      {
         # Cleanup
         $AllWallpapers = $null

         # Get a list of all of the wallpapers to choose from. Wallpaper images MUST be exactly 3840x1080, regardless if the MTR is a single or dual screen system.
         $paramGetChildItem = @{
            Path        = ($Path + '\Wallpapers')
            ErrorAction = $STP
         }
         $AllWallpapers = (Get-ChildItem @paramGetChildItem | Where-Object -FilterScript {
               $_.Extension -in '.jpg', '.jpeg', '.png', '.bmp'
         } | Select-Object -Property Name, Extension)

         # Prevent any futher action if there are no files (wallpapers)
         if (-not ($AllWallpapers))
         {
            # Just in case
            throw
         }
      }
      catch
      {
         # Create the String, just for the error message
         [string]$NewWallpaperPath = ($Path + '\Wallpapers')

         Write-Error -Message ('No wallpapers where found in {0}' -f $NewWallpaperPath) -Exception 'No wallpapers where found' -Category ObjectNotFound -RecommendedAction 'Check given path' -ErrorAction $STP

         # Just in case
         exit 1
      }
      #endregion Check
   }

   process
   {
      # Files to remove
      $FileToCleanup = @(
         'wallpaper.jpg'
         'wallpaper.jpeg'
         'wallpaper.png'
         'wallpaper.bmp'
         'SkypeSettings.xml'
      )

      # Default parameters
      $paramRemoveItem = @{
         Force         = $true
         Confirm       = $false
         ErrorAction   = $SCT
         WarningAction = $SCT
      }

      #region CleanupLoop
      foreach ($item in $FileToCleanup)
      {
         # Build the String
         $CleanupPath = ($Path + '\' + $item)

         # Check if the file exists
         if (Get-Item -Path $CleanupPath -ErrorAction $SCT)
         {
            # Add the parameter
            $paramRemoveItem.Path = $CleanupPath

            # Remove the File
            $null = (Remove-Item @paramRemoveItem)
         }

         # Cleanup
         $paramRemoveItem.Path = $null
         $CleanupPath = $null
      }
      #endregion CleanupLoop

      <#
            Pick a random wallpaper
            Keep in mind that the fewer images to choose from,
            the higher the potential to choose the same image that was used last time.
      #>
      $NewWallpaper = (Get-Random -InputObject $AllWallpapers)

      #region NewWallpaper
      if ($NewWallpaper)
      {
         # New Variables to support all extensions
         $NewWallpaperName = $NewWallpaper.Name
         $NewWallpaperFilename = ('wallpaper' + $NewWallpaper.Extension)

         if ($Check)
         {
            if (-not (Test-MtrWallpaper -Path ($Path + '\Wallpapers\' + $NewWallpaperName)))
            {
               Write-Error -Message ('Sorry, but {0} is not in the required resultion!' -f $NewWallpaperName) -Exception 'Wrong resulution' -Category InvalidData -RecommendedAction 'Check resulution' -ErrorAction $STP

               # Just in case
               exit 1
            }
         }

         Write-Verbose -Message ('Chosen wallpaper is ' + $Path + '\Wallpapers\' + $NewWallpaperName)

         # Copy the chosen wallpaper to the right folder. We rename it to a generic name as a safeguard against improper characters or file names that are too long.
         $paramCopyItem = @{
            Path          = ($Path + '\Wallpapers\' + $NewWallpaperName)
            Destination   = ($Path + '\' + $NewWallpaperFilename)
            Force         = $true
            Confirm       = $false
            ErrorAction   = $CNT
            WarningAction = $CNT
         }
         $null = (Copy-Item @paramCopyItem)

         # Create the new SkypeSettings.xml using only the fields we need to populate to configure the new wallpaper
         $paramNewObject = @{
            TypeName     = 'System.XMl.XmlTextWriter'
            ArgumentList = (($Path + '\SkypeSettings.xml'), $null)
         }
         $xmlWriter = (New-Object @paramNewObject)

         $xmlWriter.Formatting = 'Indented'
         $xmlWriter.Indentation = 1
         $xmlWriter.IndentChar = "`t"

         $xmlWriter.WriteStartDocument()
         $xmlWriter.WriteStartElement('SkypeSettings')
         $xmlWriter.WriteStartElement('Theming')
         $xmlWriter.WriteElementString('ThemeName', 'Custom')
         $xmlWriter.WriteElementString('CustomThemeImageUrl', $NewWallpaperFilename)
         $xmlWriter.WriteStartElement('CustomThemeColor')

         # Review the Color Settings!
         $xmlWriter.WriteElementString('RedComponent', $RedComponent)
         $xmlWriter.WriteElementString('GreenComponent', $GreenComponent)
         $xmlWriter.WriteElementString('BlueComponent', $BlueComponent)

         # Close CustomThemeColor
         $xmlWriter.WriteEndElement()

         # Close Theming
         $xmlWriter.WriteEndElement()

         # Close SkypeSettings
         $xmlWriter.WriteEndElement()

         # Save the XML
         $xmlWriter.WriteEndDocument()
         $xmlWriter.Flush()
         $xmlWriter.Close()
      }
      #endregion NewWallpaper
   }

   end
   {
      Write-Verbose -Message ('The new wallpaper is {0}' -f $NewWallpaper)
   }
}

New-MtrWallpaper

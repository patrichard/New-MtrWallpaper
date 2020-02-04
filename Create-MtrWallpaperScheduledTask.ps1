#requires -Version 2.0 -Modules ScheduledTasks

<#
      .SYNOPSIS
      Create a scheduled task for New-MtrWallpaper

      .DESCRIPTION
      Create a scheduled task for New-MtrWallpaper

      Just a helpper script that does some boring stuff for you!

      .EXAMPLE
      PS C:\> .\Create-MtrWallpaperScheduledTask.ps1

      .NOTES
      This doesn't seem to run well in ISE - run this in a standard PowerShell session

      It's just a minor changed version based on the great work of Pat Richard.

      .LINK
      https://www.ucunleashed.com/4323

      .LINK
      https://github.com/patrichard/New-MtrWallpaper

      .LINK
      https://adamtheautomator.com/powershell-create-scheduled-task/

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtaskaction?view=win10-ps

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasksettingsset?view=win10-ps

      .LINK
      http://duffney.io/Create-ScheduledTasks-SecurePassword
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

[string]$ThisRoot = "$env:HOMEDRIVE\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\Wallpapers"

# https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtaskaction?view=win10-ps
$paramNewScheduledTaskAction = @{
   Execute          = 'Powershell.exe'
   Argument         = "-NoProfile -ExecutionPolicy Bypass -File $ThisRoot\New-MtrWallpaper.ps1"
   WorkingDirectory = $ThisRoot
}
$action = (New-ScheduledTaskAction @paramNewScheduledTaskAction)

$paramNewScheduledTaskTrigger = @{
   Daily = $true
   At    = '12:15am'
}
$Trigger = (New-ScheduledTaskTrigger @paramNewScheduledTaskTrigger)

# https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasksettingsset?view=win10-ps
$Settings = (New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::FromHours(1)))


$UserName = ($env:USERDOMAIN + '\' + $env:USERNAME)
$SecurePassword = $password = (Read-Host -AsSecureString -Prompt ('Enter password for {0}' -f $UserName))
$Credentials = (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword)
$password = $Credentials.GetNetworkCredential().Password

$paramRegisterScheduledTask = @{
   Action      = $action
   Trigger     = $Trigger
   Settings    = $Settings
   TaskName    = 'Rotate MTR Wallpaper'
   TaskPath    = '\Microsoft\Skype'
   Description = 'This script randomly pics a new wallpaper, copies it to a folder, then write the require SkypeSettings.xml file for the MTR to use to configure the new wallpaper. For more information on the New-MtrWallpaper.ps1 script that is run, see https://www.ucunleashed.com/4323.'
   User        = $UserName
   Password    = $password
}
$null = (Register-ScheduledTask @paramRegisterScheduledTask)


#remove the password
$password = $null

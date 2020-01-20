# This doesn't seem to run well in ISE - run this in a standard PowerShell session
# https://adamtheautomator.com/powershell-create-scheduled-task/
 [string] $ThisRoot = 'C:\Users\Skype\AppData\Local\Packages\Microsoft.SkypeRoomSystem_8wekyb3d8bbwe\LocalState\Wallpapers'
# https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtaskaction?view=win10-ps
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
-Argument "-NoProfile -ExecutionPolicy Bypass -File $ThisRoot\New-MtrWallpaper.ps1" -WorkingDirectory $ThisRoot
$Trigger = New-ScheduledTaskTrigger -Daily -At 12:15am

# https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/new-scheduledtasksettingsset?view=win10-ps
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::FromHours(1))

# http://duffney.io/Create-ScheduledTasks-SecurePassword
$SecurePassword = $password = Read-Host -AsSecureString -Prompt "Enter password for $($env:USERDOMAIN)\$($env:USERNAME)"
$UserName = "$($env:USERDOMAIN)\$($env:USERNAME)"
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecurePassword
$Password = $Credentials.GetNetworkCredential().Password 

$null = Register-ScheduledTask -Action $action -Trigger $trigger -Settings $Settings -TaskName "Rotate MTR Wallpaper" -TaskPath "\Microsoft\Skype" -Description "This script randomly pics a new wallpaper, copies it to a folder, then write the require SkypeSettings.xml file for the MTR to use to configure the new wallpaper. For more information on the New-MtrWallpaper.ps1 script that is run, see https://www.ucunleashed.com/4323." -User $UserName -Password $Password

Start-ScheduledTask -TaskName 'Rotate MTR Wallpaper' -TaskPath '\Microsoft\Skype'

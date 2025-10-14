#Requires -Version 7.0
<#
  .SYNOPSIS
    Retrieves user activity events from Windows Event Log.
  .DESCRIPTION
    Gets system events related to user activity from the Windows Event Log, including 
    system startup, shutdown, sleep, wake, and power events.
  .PARAMETER StartTime
    The start time for the event query. Defaults to the beginning of the current day.
  .PARAMETER EndTime
    The end time for the event query. Defaults to the current time.
  .PARAMETER Id
    Array of event IDs to filter for. Defaults to common system activity events.
  .EXAMPLE
    Get-UserActivityEvents -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date)
  .EXAMPLE
    Get-UserActivityEvents -Id @(6005, 6006) -StartTime (Get-Date).Date
#>
Function Get-UserActivityEvents {
  param(
    [DateTime]$StartTime = (Get-Date).Date,
    [DateTime]$EndTime = (Get-Date),
    [Int[]]$Id = (
    41,   # Reboot
    42,   # Sleep
    105,  # Power Source Change
    107,  # Wake
    506,  # Enter Standby
    507,  # Exit Standby
    566,  # Session Transition
    1074, # User Shutdown
    6005, # Startup
    6006  # Shutdown
    )
  )
  $Filter = @{
    LogName = 'System';
    StartTime = $StartTime;
    EndTime = $EndTime
  }
  if ($Id) {
    $Filter.Add('Id', $Id)
  }
  Get-WinEvent -FilterHashtable $Filter -ErrorAction SilentlyContinue |
    Select-Object -Property TimeCreated, Id, Message
}

<#
  .SYNOPSIS
    Calculates user activity duration for a specific date.
  .DESCRIPTION
    Determines the duration of user activity for a given date by analyzing system events
    and assuming activity between 6 AM and the last system event of the day.
  .PARAMETER Date
    The date to calculate activity duration for. Defaults to the current date.
  .EXAMPLE
    Get-UserActivityDuration -Date (Get-Date).AddDays(-1)
  .EXAMPLE
    Get-UserActivityDuration
#>
Function Get-UserActivityDuration {
  param(
    [DateTime]$Date = (Get-Date).Date
  )
  Get-UserActivityEvents -StartTime $Date.Date -EndTime $Date.AddDays(1).Date | 
    Where-Object {$_.TimeCreated.Hour -ge 6} | # Assume system events from 12am-6am aren't user activity.
    Select-Object -ExpandProperty TimeCreated -First 1 -Last 1 |
    ForEach-Object {} {$First = $First ?? $_; $Last = $_} { $First - $Last }
}

<#
  .SYNOPSIS
    Calculates user activity durations for all available dates in the system event log.
  .DESCRIPTION
    Iterates through all available dates in the system event log and calculates
    user activity duration for each day.
  .EXAMPLE
    Get-AllUserActivityDurations
#>
Function Get-AllUserActivityDurations {
  [DateTime] $EarliestDate = Get-WinEvent -LogName System -MaxEvents 1 -Oldest | ForEach-Object {$_.TimeCreated.Date}
  for ($Date = $EarliestDate; $Date -lt (Get-Date).Date; $Date = $Date.AddDays(1))
  {
    $Duration = Get-UserActivityDuration($Date)
    $Hours = [Math]::Round($Duration.TotalHours, 2)
    @{Date=$Date;DayOfWeek=$Date.DayOfWeek;Hours=$Hours} | Select-Object -Property *
  }
}
Export-ModuleMember -Function Get-UserActivityEvents
Export-ModuleMember -Function Get-UserActivityDuration
Export-ModuleMember -Function Get-AllUserActivityDurations

#Requires -Version 7.0
<#
  .SYNOPSIS
    Gets a system's activity for a given day.
  .DESCRIPTION
    Odd system session # == start session
    Even system session # == end session
#>
Function Get-SystemActivityDuration {
  [OutputType([Timespan])]
  param(
    [Switch]$All,
    [Switch]$Average,
    [DateTime]$Date = (Get-Date).Date
  )
  $TotalDuration = New-Timespan
  $EarliestDate = [DateTime](Get-WinEvent -LogName System -MaxEvents 1 -Oldest |
    Select-Object -First 1 |
    Select-Object -ExpandProperty TimeCreated).AddDays(1).Date
  [Datetime] $EndDate = (Get-Date).AddDays(-1)
  if ($All.IsPresent)
  {
    Write-Debug "Getting total session duration from $($EarliestDate.toString("yyyy-MM-dd")) to $($EndDate.toString("yyyy-MM-dd")).";
    $TotalDuration = Get-DailySystemActivityDurations -StartDateTime $EarliestDate -EndDateTime $EndDate |
      Measure-Object -Property "TotalHours" -Sum |
      Select-Object -ExpandProperty Sum
  }
  elseif ($Average.IsPresent)
  {
    Write-Debug "Getting average daily session duration from $($Date.toString("yyyy-MM-dd")).";
    $TotalDuration = (Get-DailySystemActivityDurations -StartDateTime $EarliestDate -EndDateTime $EndDate |
      Measure-Object -Property "TotalHours" -Average |
      Select-Object -ExpandProperty Average)
  }
  else
  {
    Write-Debug "Getting sessions on day $($Date.toString("yyyy-MM-dd")).";
    [System.Diagnostics.Eventing.Reader.EventLogRecord[]] $Events = (
      Get-WinEvent -FilterHashtable @{
        StartTime=$Date.Date;
        Endtime=$Date.Date.AddDays(1);
        LogName='System';
        Id=(506,507);
      } -ErrorAction SilentlyContinue
    ) ?? @()
    # TODO: Sometimes the system doesn't end a session when logging out. But if the user didn't actually logout, then that time isn't counted but should be included.
    $CurrentStartTime = $Events[-1].TimeCreated

    for ($i = $Events.count - 1; $i -ge 0; $i--)
    {
      if ($Events[$i].Id -eq 506)
      {
        $SessionDuration = $Events[$i].TimeCreated - $CurrentStartTime
        $TotalDuration += $SessionDuration
        Write-Debug "Ended session @ $($Events[$i].TimeCreated). SessionDuration: $($SessionDuration). TotalDuration: $TotalDuration"
      }
      else
      {
        Write-Debug "Began session @ $($Events[$i].TimeCreated)."
        $CurrentStartTime = $Events[$i].TimeCreated
      }
    }
    if ($Events[0].Id -eq 507)
    {
      [TimeSpan]$Overtime = $Date.Date.AddDays(1) - $Events[0].TimeCreated
      $TotalDuration += $Overtime
      Write-Debug "OverT @ $($Date.Date.AddDays(1)). Duration: $($Overtime) hours. Total: $TotalDuration"
    }
  }
  $TotalDuration
}

Function Get-DailySystemActivityDurations {
  [OutputType([Timespan[]])]
  param(
    [Int]$DaysBack = 1,
    [DateTime]$StartDateTime = (Get-Date).AddDays(-$DaysBack).Date,
    [DateTime]$EndDateTime = (Get-Date).Date
  )
  [System.Collections.Generic.List[Timespan]] $Durations = @()
  [System.Diagnostics.Eventing.Reader.EventLogRecord[]] $Events = (
    Get-WinEvent -FilterHashtable @{
      StartTime=$StartDateTime;
      Endtime=$EndDateTime;
      LogName='System';
      Id=(506,507);
    } -ErrorAction SilentlyContinue
  ) ?? @()
  $CurrentDateTime = $StartDateTime.Date
  while ($CurrentDateTime -lt $EndDateTime)
  {
    [Timespan]$Duration = Get-SystemActivityDuration -Date $CurrentDateTime
    $Durations.Add($Duration)
    $CurrentDateTime = $CurrentDateTime.AddDays(1)
  }
  return $Durations
}

Export-ModuleMember -Function Get-SystemActivityDuration

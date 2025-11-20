# phamshell
## about
**phamshell** is a growing collection of modules and libraries intended to help build shell applications or run ad hoc scripts.  
author chrisdavidpham  
contact chris@chrisdavidpham.com  
## Usage
Import the module into your script or cli to use phamshell.
```ps1
Import-Module ".\phamshell.psd1"

Get-Module "phamshell"
```
|ModuleType|Version|PreRelease|Name     |ExportedCommands                   |
|----------|-------|----------|---------|-----------------------------------|
|Script    |1.0.0  |          |phamshell|{Get-DailySystemActivityDurations, ...}|
```ps1
Get-SystemActivityEvents
```
|TimeCreated            |Id |Message|
|-----------------------|---|-------|
|10/14/2025 11:34:20 AM |566|The system session has transitioned from 132 to 134.…
|10/14/2025 11:34:20 AM |507|The system is exiting Modern Standby …
```ps1
Get-SystemActivityDuration(Get-Date)
```
> Days              : 0  
> Hours             : 1  
> Minutes           : 23  
> Seconds           : 47  
> Milliseconds      : 109  
> Ticks             : 50271099827  
> TotalDays         : 0.058184143318287  
> TotalHours        : 1.39641943963889  
> TotalMinutes      : 83.7851663783333  
> TotalSeconds      : 5027.1099827  
> TotalMilliseconds : 5027109.9827
## Examples
```ps1
Get-DailySystemActivityDurations | Where-Object {$_.Hours -gt 0} | Measure-Object -AllStats -Property Hours
```
> Count             : 99  
> Average           : 8.22444444444445  
> Sum               : 814.22  
> Maximum           : 14.66  
> Minimum           : 0.18  
> StandardDeviation : 2.8997555217928  
> Property          : Hours

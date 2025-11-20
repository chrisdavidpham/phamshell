@{
  RootModule = 'phamshell.psm1'
  ModuleVersion = '1.0.0'
  GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
  Author = 'phamshell'
  CompanyName = 'Unknown'
  Copyright = '(c) phamshell. All rights reserved.'
  Description = 'PowerShell module for analyzing Windows system activity and user activity duration from event logs.'
  PowerShellVersion = '7.0'
  FunctionsToExport = @(
    'Get-UserActivityEvents',
    'Get-UserActivityDuration',
    'Get-AllUserActivityDurations'
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @()
  PrivateData = @{
    PSData = @{
      Prerelease = 'alpha2'
      Tags = @('Windows', 'EventLog', 'SystemActivity', 'UserActivity', 'PowerShell')
      LicenseUri = ''
      ProjectUri = ''
      IconUri = ''
      ReleaseNotes = 'Initial release of phamshell module for Windows system activity analysis.'
    }
  }
}

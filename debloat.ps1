if ($env:SYSTEMDRIVE -eq "X:")
{
  $script:Offline = $true

  # Find Windows
  $drives = Get-Volume | Where-Object { -not [string]::IsNullOrWhiteSpace($_.DriveLetter) -and $_.DriveType -eq 'Fixed' -and $_.DriveLetter -ne 'X' }
  $drives | Where-Object { Test-Path "$($_.DriveLetter):\Windows\System32" } | ForEach-Object { $script:OfflinePath = "$($_.DriveLetter):\" }
  Write-Verbose "Eligible offline drive found: $script:OfflinePath"
}
else
{
  Write-Verbose "Running in the full OS."
  $script:Offline = $false
}

# ---------------------------------------------------------------------------
# Get-LogDir:  Return the location for logs and output files
# ---------------------------------------------------------------------------

function Get-LogDir
{
  try
  {
    $ts = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
    if ($ts.Value("LogPath") -ne "")
    {
      $logDir = $ts.Value("LogPath")
    }
    else
    {
      $logDir = $ts.Value("_SMSTSLogPath")
    }
  }
  catch
  {
    $logDir = $env:TEMP
  }
  return $logDir
}

# ---------------------------------------------------------------------------
# Get-AppList:  Return the list of apps to be removed
# ---------------------------------------------------------------------------

function Get-AppList
{
  $list = @(
    'Microsoft.BingWeather',
    'Microsoft.GetHelp',
    'Microsoft.Getstarted',
    'Microsoft.Messaging',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.Office.OneNote',
    'Microsoft.OneConnect',
    'Microsoft.People',
    'Microsoft.Print3D',
    'Microsoft.SkypeApp',
    'Microsoft.Wallet',
    'microsoft.windowscommunicationsapps',
    'Microsoft.WindowsFeedbackHub',
    'Microsoft.Xbox.TCUI',
    'Microsoft.XboxApp',
    'Microsoft.XboxGameOverlay',
    'Microsoft.XboxGamingOverlay',
    'Microsoft.XboxIdentityProvider',
    'Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.YourPhone',
    'Microsoft.ZuneMusic',
    'Microsoft.ZuneVideo',
    'Microsoft.MicrosoftStickyNotes',
    'Microsoft.WindowsMaps',
    'Microsoft.Microsoft3DViewer',
    'Microsoft.OutlookForWindows',
    'Microsoft.Clipchamp.Clipchamp',
    'Microsoft.MSTeams',
    'Microsoft.OutlookForWindows',
    'Microsoft.bingnews',
    'Microsoft.GamingApp_2501.1001.3.0_x64__8wekyb3d8bbwe'
  )

  Write-Information "Apps selected for removal: $($list.Count)"
  return $list
}

# ---------------------------------------------------------------------------
# Remove-App:  Remove the specified app (online or offline)
# ---------------------------------------------------------------------------

function Remove-App
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string] $appName
  )

  begin
  {
    if ($script:Offline)
    {
      $script:Provisioned = Get-AppxProvisionedPackage -Path $script:OfflinePath
    }
    else
    {
      $script:Provisioned = Get-AppxProvisionedPackage -Online
      $script:AppxPackages = Get-AppxPackage
    }
  }

  process
  {
    $app = $_

    Write-Information "Removing provisioned package $app"
    $current = $script:Provisioned | Where-Object { $_.DisplayName -eq $app }
    if ($current)
    {
      if ($script:Offline)
      {
        Remove-AppxProvisionedPackage -Path $script:OfflinePath -PackageName $current.PackageName | Out-Null
      }
      else
      {
        Remove-AppxProvisionedPackage -Online -PackageName $current.PackageName | Out-Null
      }
    }
    else
    {
      Write-Warning "Provisioned package not found: $app"
    }

    if (-not $script:Offline)
    {
      Write-Information "Removing installed package $app"
      $current = $script:AppxPackages | Where-Object { $_.Name -eq $app }
      if ($current)
      {
        $current | Remove-AppxPackage | Out-Null
      }
      else
      {
        Write-Warning "Installed app not found: $app"
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

$logDir = Get-LogDir
Start-Transcript "$logDir\RemoveApps.log"

Get-AppList | Remove-App

Stop-Transcript

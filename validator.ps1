Write-Host "Running image validation..."

# Check for updates history
$updates = Get-HotFix
if (-not $updates) {
    Write-Error "No Windows Updates found. Validation failed."
    exit 1
}

# Check if unwanted apps are gone
$appsToCheck = @(
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
    'Microsoft.bingnews',
    'Microsoft.GamingApp_2501.1001.3.0_x64__8wekyb3d8bbwe'
)

$provisionedApps = Get-AppxProvisionedPackage -Online | Select-Object -ExpandProperty DisplayName

$found = $appsToCheck | Where-Object { $provisionedApps -contains $_ }

if ($found.Count -gt 0) {
    Write-Error "Validation failed. The following unwanted provisioned apps are still present:`n$($found -join "`n")"
    exit 1
} else {
    Write-Host "Validation passed. No unwanted provisioned apps found."
}

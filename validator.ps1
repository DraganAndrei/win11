Write-Host "Running image validation..."

# Check for updates history
$updates = Get-HotFix
if (-not $updates) {
    Write-Error "No Windows Updates found. Validation failed."
    exit 1
}

# Check if unwanted app is gone
if (Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "Microsoft.BingWeather"}) {
    Write-Error "Microsoft.BingWeather still exists. Debloat failed."
    exit 1
}

Write-Host "Validation passed."

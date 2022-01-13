# !!ITEMS!! are placeholders for injecting strings via vagrant plugin
Write-Host "Downloading RKE2 installer for Windows..."
Invoke-WebRequest -Uri !!INSTALL_URL!! -Outfile install.ps1

Write-Host "Creating RKE2 configuration..."
New-Item -Type Directory C:/etc/rancher/rke2 -Force
Set-Content -Path C:/etc/rancher/rke2/config.yaml -Value @"
!!CONFIG!!
"@

Write-Host "Installing RKE2 as an agent..."
./install.ps1 !!ENV!!

Write-Host "Creating RKE2 environment variables..."
$env:PATH+=";C:\var\lib\rancher\rke2\bin;c:\usr\local\bin"
[Environment]::SetEnvironmentVariable("Path",
        [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\var\lib\rancher\rke2\bin;c:\usr\local\bin",
        [EnvironmentVariableTarget]::Machine)

# Write-Host "Starting RKE2 Windows Service..."
# Push-Location c:\usr\local\bin
# rke2.exe agent service --add
# exit 0
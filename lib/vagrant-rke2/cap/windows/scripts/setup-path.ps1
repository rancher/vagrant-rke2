Write-Host "Creating RKE2 environment variables..."
$env:PATH+=";C:\var\lib\rancher\rke2\bin;c:\usr\local\bin"
[Environment]::SetEnvironmentVariable("Path",
        [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\var\lib\rancher\rke2\bin;c:\usr\local\bin",
        [EnvironmentVariableTarget]::Machine)
# !!ITEMS!! are placeholders for injecting strings via vagrant plugin
Write-Host "Downloading RKE2 installer for Windows..."
Invoke-WebRequest -Uri !!INSTALL_URL!! -Outfile install.ps1

Write-Host "Creating RKE2 configuration..."
New-Item -Type Directory C:/etc/rancher/rke2 -Force
Set-Content -Path !!CONFIG_PATH!! -Value @"
!!CONFIG!!
"@

Write-Host "Installing RKE2 as an agent..."
./install.ps1 !!ENV!!

Write-Host "Open ports for RKE2 and Calico in firewall..."
netsh advfirewall firewall add rule name= "RKE2-kubelet" dir=in action=allow protocol=TCP localport=10250
netsh advfirewall firewall add rule name= "RKE2-agent" dir=in action=allow protocol=TCP localport=4789

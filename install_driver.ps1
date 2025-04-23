# Requires Administrator

$hardwareID = "USB\VID_1A86&PID_7523"
$desiredDriverVersion = "3.5.2019.1"
$driverPath = Join-Path $PSScriptRoot "modbus_driver\modbusdriver2019.inf"


# Function disable automatic updates
function Disable-AutoDriverUpdates {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -Type DWord
    Write-Host "Automatic driver updates via Windows Update disabled."
}

# Step 1: Check if correct driver is installed
$installedDriver = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceID -like "*$hardwareID*" }

if ($installedDriver) {
    if ($installedDriver.DriverVersion -eq $desiredDriverVersion) {
        Write-Host "Correct driver version is already installed: $desiredDriverVersion"
        Disable-AutoDriverUpdates
        exit
    } else {
        Write-Host "Installed driver version is $($installedDriver.DriverVersion). Replacing it..."
    }
} else {
    Write-Host "Device not currently installed. Proceeding to install driver."
}

# Step 2: Remove device instance(s)
$devicesToRemove = Get-WmiObject Win32_PnPEntity | Where-Object { $_.DeviceID -like "*$hardwareID*" }

foreach ($device in $devicesToRemove) {
    Write-Host "Removing device instance: $($device.PNPDeviceID)"
    pnputil /remove-device "$($device.PNPDeviceID)"
}

# Step 3: Remove existing driver packages from driver store
$driverPackages = pnputil /enum-drivers | Select-String -Pattern "Published Name|Provider Name|Driver Version"

# Parse results to find matching oemXX.inf files for this hardware
$oemFiles = @()
for ($i=0; $i -lt $driverPackages.Count; $i++) {
    if ($driverPackages[$i] -match "Published Name\s*:\s*(oem\d+\.inf)") {
        $oem = $Matches[1]
        $provider = $driverPackages[$i+1]
        $version = $driverPackages[$i+2]

        if ($provider -like "*wch.cn*" -or $provider -like "*CH340*" -or $provider -like "*1A86*" -or $version -like "*$hardwareID*") {
            $oemFiles += $oem
        }
    }
}

if ($oemFiles.Count -gt 0) {
    $oemFiles | ForEach-Object {
        Write-Host "Removing existing driver package: $_"
        pnputil /delete-driver $_ /uninstall /force
    }
} else {
    Write-Host "No conflicting driver packages found in driver store."
}

# Step 4: Install correct driver
Write-Host "Installing driver from: $driverPath"
pnputil /add-driver "$driverPath" /install

# Step 5: Disable automatic updates
Disable-AutoDriverUpdates

Write-Host "`nAll done! Please reconnect the device if it was unplugged."

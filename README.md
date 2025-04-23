# Modbus Driver Installer

Simple Windows utility to install the 3.5.2019.1 Modbus driver and disable automatic driver updates.

## 📦 Contents

- `modbus_driver/` — contains `modbusdriver2019.inf`
- `install_driver.ps1` — PowerShell script to manage the driver
- `run_driver_update.bat` — double-click to run everything

## 🛠️ Requirements

- Windows 10+
- Administrator rights

## 🚀 How to Use

1. Clone or download this repo:
   ```bash
   git clone https://github.com/EmalisaAntonioli/modbus_driver_fix.git

2. Open the folder.

3. Run run_driver_update.bat as administrator.

4. Reconnect your device when done.

5. If changes don't take effect immediately: reboot the PC

📌 What It Does

    Disables Windows automatic driver updates

    Removes old/conflicting drivers for your device

    Installs the correct driver from the driver/ folder

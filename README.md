# System Info Tool

A PowerShell script that displays a clean summary of key system information on Windows.

## Output

- **OS** — name, version, and build number
- **Computer** — hostname
- **CPU** — model, core count, and logical processor count
- **Memory** — total RAM
- **Disk** — total and free space on C:
- **Network** — IP address, default gateway, and DNS servers for each active physical adapter (Wi-Fi and/or Ethernet); virtual adapters (WSL, Hyper-V, VMware, etc.) are excluded

## Requirements

- Windows 10 or 11
- PowerShell 5.1 or later

## Usage

```powershell
.\Get-SystemInfo.ps1
```

If you get an execution policy error, run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Example Output

```
===== SYSTEM INFORMATION =====

[Operating System]
  Name   : Microsoft Windows 11 Pro
  Version: 10.0.26200  (Build 26200)

[Computer]
  Name: SID

[CPU]
  Model: Intel(R) Core(TM) Ultra 7 155U
  Cores: 12  Logical Processors: 14

[Memory]
  Total RAM: 15.45 GB

[Disk - C:\]
  Total : 952.87 GB
  Free  : 735.8 GB

[Network]

  [Wi-Fi] Intel(R) Wi-Fi 6E AX211 160MHz
    Status     : Up
    IP Address : 10.0.0.235
    Gateway    : 10.0.0.1
    DNS Servers: 75.75.75.75, 75.75.76.76

==============================
```

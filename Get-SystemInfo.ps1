# Get-SystemInfo.ps1
# Displays a summary of key system information in a readable format.
#
# If blocked by execution policy, run once in an elevated PowerShell session:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

Write-Host "`n===== SYSTEM INFORMATION =====" -ForegroundColor Cyan

# --- OS Name and Version ---
$os = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Host "`n[Operating System]" -ForegroundColor Yellow
Write-Host "  Name   : $($os.Caption)"
Write-Host "  Version: $($os.Version)  (Build $($os.BuildNumber))"

# --- Computer Name ---
Write-Host "`n[Computer]" -ForegroundColor Yellow
Write-Host "  Name: $env:COMPUTERNAME"

# --- CPU Model ---
$cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
Write-Host "`n[CPU]" -ForegroundColor Yellow
Write-Host "  Model: $($cpu.Name.Trim())"
Write-Host "  Cores: $($cpu.NumberOfCores)  Logical Processors: $($cpu.NumberOfLogicalProcessors)"

# --- Total RAM ---
# Divide bytes -> GB and round to two decimal places.
$ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
Write-Host "`n[Memory]" -ForegroundColor Yellow
Write-Host "  Total RAM: $ramGB GB"

# --- Free Disk Space on C: ---
$disk = Get-PSDrive -Name C
$freeGB  = [math]::Round($disk.Free  / 1GB, 2)
$totalGB = [math]::Round(($disk.Used + $disk.Free) / 1GB, 2)
Write-Host "`n[Disk - C:\]" -ForegroundColor Yellow
Write-Host "  Total : $totalGB GB"
Write-Host "  Free  : $freeGB GB"

# --- Active Physical Network Adapters (Wi-Fi and/or Ethernet) ---
# Exclude virtual adapters: WSL, Hyper-V, VirtualBox, VMware, loopback, and
# tunnel/ISATAP interfaces. Only include adapters that are Up and have a real IPv4.
$virtualPattern = 'Hyper-V|WSL|VirtualBox|VMware|Loopback|isatap|Teredo|6to4|Pseudo'

$activeAdapters = Get-NetAdapter |
    Where-Object {
        $_.Status -eq 'Up' -and
        $_.InterfaceDescription -notmatch $virtualPattern -and
        $_.Name -notmatch $virtualPattern -and
        $_.PhysicalMediaType -ne 'Unspecified'   # filters most virtual NICs
    }

Write-Host "`n[Network]" -ForegroundColor Yellow

if ($activeAdapters) {
    foreach ($adapter in $activeAdapters) {
        # Determine a friendly label: Wi-Fi or Ethernet
        $label = if ($adapter.InterfaceDescription -match 'Wi.?Fi|Wireless' -or
                     $adapter.Name -match 'Wi.?Fi|Wireless') { 'Wi-Fi' } else { 'Ethernet' }

        # Fetch the IPv4 config for this specific interface index
        $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.ifIndex

        $ipv4 = ($ipConfig.IPv4Address | Select-Object -First 1).IPAddress
        $gw   = ($ipConfig.IPv4DefaultGateway | Select-Object -First 1).NextHop
        $dns  = ($ipConfig.DNSServer | Where-Object { $_.AddressFamily -eq 2 }).ServerAddresses -join ', '

        Write-Host "`n  [$label] $($adapter.InterfaceDescription)"
        Write-Host "    Status     : $($adapter.Status)"
        Write-Host "    IP Address : $(if ($ipv4) { $ipv4 } else { 'N/A' })"
        Write-Host "    Gateway    : $(if ($gw)   { $gw   } else { 'N/A' })"
        Write-Host "    DNS Servers: $(if ($dns)  { $dns  } else { 'N/A' })"
    }
} else {
    Write-Host "  No active physical network adapters found."
}

Write-Host "`n==============================`n" -ForegroundColor Cyan

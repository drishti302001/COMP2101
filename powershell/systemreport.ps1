function SystemInformation {
    $systemHardware = Get-CimInstance Win32_ComputerSystem
    $operatingSystem = Get-CimInstance Win32_OperatingSystem
    $videoControllers = Get-CimInstance Win32_VideoController
    $ramInfo = Get-CimInstance Win32_PhysicalMemory
    $totalRAM = ($ramInfo | Measure-Object Capacity -Sum).Sum / 1GB

    Write-Host ("=" * 40)
    Write-Host "System Hardware Information"
    Write-Host "Manufacturer: $($systemHardware.Manufacturer)"
    Write-Host "Model: $($systemHardware.Model)"
    Write-Host "Total Physical Memory: $([math]::Round($systemHardware.TotalPhysicalMemory / 1GB, 2)) GB"
    Write-Host "System Type: $($systemHardware.SystemType)"
    Write-Host ("=" * 40)
    Write-Host

    Write-Host "Operating System Information"
    Write-Host "Name: $($operatingSystem.Caption)"
    Write-Host "Version: $($operatingSystem.Version)"
    Write-Host "Build Number: $($operatingSystem.BuildNumber)"
    Write-Host "Service Pack: $($operatingSystem.CSDVersion)"
    Write-Host "Architecture: $($operatingSystem.OSArchitecture)"
    Write-Host ("=" * 40)
    Write-Host

    foreach ($controller in $videoControllers) {
        $resolution = "$($controller.CurrentHorizontalResolution) x $($controller.CurrentVerticalResolution)"

        Write-Host ("=" * 40)
        Write-Host "Video Card Information"
        Write-Host "Vendor: $($controller.VideoProcessor)"
        Write-Host "Description: $($controller.Description)"
        Write-Host "Current Resolution: $resolution"
        Write-Host ("=" * 40)
        Write-Host
    }
    $ramTable = $ramInfo | ForEach-Object {
        [PSCustomObject]@{
            Vendor = $_.Manufacturer
            Description = $_.PartNumber
            SizeGB = [math]::Round($_.Capacity / 1GB, 2)
            Bank = $_.BankLabel
            Slot = $_.DeviceLocator
        }
    }

    $ramTable | Format-Table -AutoSize

    # Display total RAM summary
    Write-Host
    Write-Host "Total Installed RAM: $totalRAM GB"
    Write-Host
}


function NetworkAdapterInfo {
    $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

    $reportData = foreach ($adapter in $adapters) {
        [PSCustomObject]@{
            AdapterDescription = $adapter.Description
	    Index = $adapter.Index
            IPAddresses = $adapter.IPAddress -join ', '
            SubnetMasks = $adapter.IPSubnet -join ', '
            DNSDomain = $adapter.DNSDomain
            DNS = $adapter.DNSServerSearchOrder -join ', '
        }
    }

    return $reportData
}

function DiskDriveInfo {
    $diskDrives = Get-CimInstance Win32_DiskDrive

    $diskInformation = foreach ($disk in $diskDrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition

        foreach ($partition in $partitions) {
            $logicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk

            foreach ($logicalDisk in $logicalDisks) {
                [PSCustomObject]@{
                    Manufacturer = $disk.Manufacturer
        	    Model = $disk.Model
                    SizeGB = [math]::Round($disk.Size / 1GB, 2)
                    Drive = $logicalDisk.DeviceID
                    FreeSpaceGB = [math]::Round($logicalDisk.FreeSpace / 1GB, 2)
                }
            }
        }
    }

    return $diskInformation
}

SystemInformation
NetworkAdapterInfo
DiskDriveInfo

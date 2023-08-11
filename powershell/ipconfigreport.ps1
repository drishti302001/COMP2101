#Script to create a report of IP configuration

#Network adapter configuration objects and filter for enabled adapters
$adapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

#Custom object for each adapter
$reportData = foreach ($adapter in $adapters) {
    [PSCustomObject]@{
        AdapterDescription = $adapter.Description
        Index = $adapter.Index
        IPAddress = $adapter.IPAddress -join ', '
        SubnetMask = $adapter.IPSubnet -join ', '
        DNSDomain = $adapter.DNSDomain
        DNSServer = $adapter.DNSServerSearchOrder -join ', '
    }
}

#Format and display the report
$reportData | Format-Table -AutoSize
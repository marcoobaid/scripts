#$ActiveInterface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -ExpandProperty InterfaceIndex
#if ($ActiveInterface) {
#    $PrimaryDNS = (Get-DnsClientServerAddress -InterfaceIndex $ActiveInterface -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses)[0]
#    if ($PrimaryDNS) {
#        Write-Output "Primary DNS: $PrimaryDNS"
#    }
#    else {
#        Write-Output "No DNS server found."
#    }
#}
$ActiveInterface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -ExpandProperty InterfaceIndex
if ($ActiveInterface) {
    $DNSServers = @(Get-DnsClientServerAddress -InterfaceIndex $ActiveInterface -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses)

    if ($DNSServers.Count -gt 0) {
        $PrimaryDNS = $DNSServers[0]  # Safely gets the first DNS server
        Write-Output "Primary DNS: $PrimaryDNS"
    }
    else {
        Write-Output "No DNS server found."
    }
}
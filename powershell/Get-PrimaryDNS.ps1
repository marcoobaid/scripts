<#
.SYNOPSIS
    Script to get the primary DNS server of the active network interface.

.DESCRIPTION
    This script identifies the active network interface with an IPv4 default gateway,
    retrieves its DNS server addresses, and outputs the primary DNS server.

.AUTHOR
    Marco Obaid
    Email: marco@obaid.pro
    GitHub: https://github.com/marcoobaid

.LICENSE
    MIT License

.EXAMPLE
    .\Get-PrimaryDNS.ps1

.NOTES
    Ensure the execution policy allows running scripts.
    You can set the execution policy with the following command:
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>

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
else {
    Write-Output "No active network interface found."
}

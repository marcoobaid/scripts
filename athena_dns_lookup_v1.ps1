<#
.SYNOPSIS
    Script to resolve DNS for a HOST and count unique resolved IP addresses.
.DESCRIPTION
    This script resolves the specified domain name using the specified DNS server
    at regular intervals, clears the DNS cache before each run, and counts the 
    occurrences of unique IP addresses resolved.
.AUTHOR
    Marco Obaid
    Email: marco@obaid.pro
    GitHub: https://github.com/marcoobaid
.LICENSE
    MIT License
.EXAMPLE
    .\dns_lookup_count.ps1
.NOTES
    Ensure the execution policy allows running scripts. 
    You can set the execution policy with the following command:
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>

# Initialize variables for the DNS server and domain name
$dnsServer = "8.8.8.8"
$domainName = "athenanet.athenahealth.com"

# Initialize a hashtable to store IP address counts
$ipAddressCounts = @{}
Write-Output "Using ${dnsServer} DNS Server"
Write-Output "Starting DNS resolution for ${domainName} ..."

# Run the command every 20 seconds for a period of 15 minutes
$endTime = (Get-Date).AddSeconds(900)
while ((Get-Date) -lt $endTime) {
    # Clear DNS cache
    Clear-DnsClientCache
    #Write-Output "DNS cache cleared successfully."

    # Resolve the DNS name using the specified DNS server
    $result = Resolve-DnsName -Name $domainName -Server $dnsServer
    
    # Extract the IP address
    $ipAddress = ($result | Where-Object { $_.QueryType -eq "A" }).IPAddress

    # Output the resolved IP address for debugging
    Write-Output "Resolved IP Address: $ipAddress"

    # Update the IP address count
    if ($ipAddressCounts.ContainsKey($ipAddress)) {
        $ipAddressCounts[$ipAddress]++
    }
    else {
        $ipAddressCounts[$ipAddress] = 1
    }

    # Wait for 20 seconds before running the command again
    Start-Sleep -Seconds 20
}

# Print the counts of unique IP addresses
Write-Output "Occurrences of unique IP address values:"
foreach ($ipAddress in $ipAddressCounts.Keys) {
    Write-Output "${ipAddress}: $($ipAddressCounts[$ipAddress])"
}

Write-Output "Script completed."

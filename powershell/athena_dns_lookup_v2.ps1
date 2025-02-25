<# 
.SYNOPSIS 
    Script to resolve DNS and count unique IP addresses. 
.DESCRIPTION 
    This script resolves the specified DNS name using the specified DNS server at regular intervals, clears the DNS cache, and counts the occurrences of unique IP addresses resolved. 
.AUTHOR 
    Marco Obaid 
    Email: marco@obaid.pro 
    GitHub: https://github.com/marcoobaid 
.LICENSE 
    MIT License 
.EXAMPLE 
    .\example_script.ps1 
.NOTES 
    Ensure the execution policy allows running scripts. 
    You can set the execution policy with the following command: 
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser 
#> 

# Initialize variables for the DNS server and domain name
$dnsServer = ""
$domainName = "athenanet.athenahealth.com"
$logFile = "dns_resolution_log.txt"
$computerName = $env:COMPUTERNAME

# Get the active interface and DNS servers
$ActiveInterface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -ExpandProperty InterfaceIndex
if ($ActiveInterface) {
    $DNSServers = @(Get-DnsClientServerAddress -InterfaceIndex $ActiveInterface -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses)
    if ($DNSServers.Count -gt 0) {
        $setDNS = $DNSServers[0]  # Safely gets the first DNS server
    }
}

# Function to display the selection menu and get the user's choice
function Get-DnsServerSelection {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "*******************************************************************"
        Write-Host "${computerName} is currently set to use $setDNS for DNS"
        Write-Host "*******************************************************************"
        Write-Host "Please select the DNS server to test ${domainName}:"
        Write-Host "1. Cloudflare 1.1.1.1"
        Write-Host "2. Google DNS 8.8.8.8"
        Write-Host "3. Quad9 9.9.9.9"
        Write-Host "4. OpenDNS 208.67.222.222"
        Write-Host "5. Current interface setting $setDNS"
        Write-Host "6. Exit"
        Write-Host "*******************************************************************"
        $selection = Read-Host "Enter the number of your selection"
        switch ($selection) {
            1 { Clear-Host; return "1.1.1.1" }
            2 { Clear-Host; return "8.8.8.8" }
            3 { Clear-Host; return "9.9.9.9" }
            4 { Clear-Host; return "208.67.222.222" }
            5 { Clear-Host; return $setDNS }
            6 { Write-Host "Scritp has been terminated"; exit }
            default { Write-Host "Invalid selection. Please try again!" }
        }
    }
}

# Get the user's DNS server selection
$dnsServer = Get-DnsServerSelection

# Initialize a hashtable to store IP address counts
$ipAddressCounts = @{}
$timestamp = Get-Date -Format "dddd M/dd/yyyy h:mm tt"
Write-Output "$timestamp" | Out-File -FilePath $logFile -Append
Write-Output "$timestamp"
Write-Output "********************************************************************"
Write-Output "********************************************************************" | Out-File -FilePath $logFile -Append
Write-Output "${computerName} is currently set to use $setDNS for DNS"
Write-Output "${computerName} is currently set to use $setDNS for DNS" | Out-File -FilePath $logFile -Append
Write-Output "Resolving ${domainName} by querying $dnsServer ..."
Write-Output "Resolving ${domainName} by querying $dnsServer ..." | Out-File -FilePath $logFile -Append
Write-Output "*********************************************************************"
Write-Output "*********************************************************************" | Out-File -FilePath $logFile -Append

# Run the command every 20 seconds for a period of 15 minutes
$endTime = (Get-Date).AddMinutes(15) # Updated to run for 15 minutes
while ((Get-Date) -lt $endTime) {
    # Clear DNS cache
    Clear-DnsClientCache
    
    # Resolve the DNS name using the specified DNS server
    $result = Resolve-DnsName -Name $domainName -Server $dnsServer
    
    # Extract the IP address
    $ipAddress = ($result | Where-Object { $_.QueryType -eq "A" }).IPAddress
    
    # Output the resolved IP address for debugging
    Write-Output "Resolved IP Address: $ipAddress" | Out-File -FilePath $logFile -Append
    Write-Output "Resolved IP Address: $ipAddress"
    
    # Update the IP address count
    if ($ipAddressCounts.ContainsKey($ipAddress)) {
        $ipAddressCounts[$ipAddress]++
    }
    else {
        $ipAddressCounts[$ipAddress] = 1
    }
    
    # Wait for 20 seconds before running the command again
    Start-Sleep -Seconds 20 # Default: 20
}

# Print the counts of unique IP addresses
Write-Output "*********************************************************************"
Write-Output "*********************************************************************" | Out-File -FilePath $logFile -Append
Write-Output "Summary of DNS Resolutions by unique resolved IPs:" | Out-File -FilePath $logFile -Append
Write-Output "Summary of DNS Resolutions by unique resolved IPs:"
foreach ($ipAddress in $ipAddressCounts.Keys) {
    Write-Output "${ipAddress}: $($ipAddressCounts[$ipAddress])" | Out-File -FilePath $logFile -Append
    Write-Output "${ipAddress}: $($ipAddressCounts[$ipAddress])"
}
Write-Output "*********************************************************************"
Write-Output "*********************************************************************" | Out-File -FilePath $logFile -Append
Write-Output "Script completed." | Out-File -FilePath $logFile -Append
Write-Output "Script completed."
Write-Output ""

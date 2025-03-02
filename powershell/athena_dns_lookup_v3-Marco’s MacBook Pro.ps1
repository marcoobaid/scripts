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

# Default test parameters
$sleepSeconds = 20  # Wait for 20 seconds before running the command again
$durationMinutes = 15  # Run the command for a period of 15 minutes

# Get the active interface and DNS servers
$ActiveInterface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -ExpandProperty InterfaceIndex
if ($ActiveInterface) {
    $DNSServers = Get-DnsClientServerAddress -InterfaceIndex $ActiveInterface -AddressFamily IPv4 | 
    Select-Object -ExpandProperty ServerAddresses
    if ($DNSServers -is [array] -and $DNSServers.Count -gt 0) {
        $setDNS = [string]$DNSServers[0]  # Explicitly cast to string
    }
    elseif ($DNSServers) {
        $setDNS = [string]$DNSServers  # Explicitly cast to string
    }
    else {
        $setDNS = "No DNS server found"
    }
}

# Function to display the selection menu and get the user's choice
function Get-DnsServerSelection {
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "*************************************************************************"
        Write-Host "${computerName} active interface is currently set to $setDNS for DNS"
        Write-Host "*************************************************************************"
        Write-Host "Please select the DNS server to query ${domainName}:"
        Write-Host "1. Cloudflare 1.1.1.1"
        Write-Host "2. Google DNS 8.8.8.8"
        Write-Host "3. Quad9 9.9.9.9"
        Write-Host "4. OpenDNS 208.67.222.222"
        Write-Host "5. Current interface setting"
        Write-Host "6. Set Interval and Duration parameters (Current: ${sleepSeconds}s interval, ${durationMinutes}m duration)"
        Write-Host "7. Exit"
        Write-Host "*************************************************************************"
        $selection = Read-Host "Enter the number of your selection"
        switch ($selection) {
            1 { Clear-Host; return "1.1.1.1".Trim() }
            2 { Clear-Host; return "8.8.8.8".Trim() }
            3 { Clear-Host; return "9.9.9.9".Trim() }
            4 { Clear-Host; return "208.67.222.222".Trim() }
            5 { Clear-Host; return $setDNS.Trim() }
            6 { Clear-Host; Set-TestParameters; continue }
            7 { Write-Host "Script has been terminated"; exit }
            default { Write-Host "Invalid selection. Please try again!" }
        }
    }
}

# Function to set interval and duration parameters
function Set-TestParameters {
    Write-Host ""
    Write-Host "*******************************************************************"
    Write-Host "Configure Test Parameters"
    Write-Host "*******************************************************************"
    Write-Host "Current Settings:"
    Write-Host "Interval: $sleepSeconds seconds"
    Write-Host "Duration: $durationMinutes minutes"
    Write-Host ""
    
    # Get new interval value (with validation)
    $validInterval = $false
    while (-not $validInterval) {
        $newInterval = Read-Host "Enter new interval in seconds (1-60)"
        if ($newInterval -match "^\d+$" -and [int]$newInterval -ge 1 -and [int]$newInterval -le 60) {
            $script:sleepSeconds = [int]$newInterval
            $validInterval = $true
        }
        else {
            Write-Host "Invalid input. Please enter a number between 1 and 60."
        }
    }
    
    # Get new duration value (with validation)
    $validDuration = $false
    while (-not $validDuration) {
        $newDuration = Read-Host "Enter new duration in minutes (1-120)"
        if ($newDuration -match "^\d+$" -and [int]$newDuration -ge 1 -and [int]$newDuration -le 120) {
            $script:durationMinutes = [int]$newDuration
            $validDuration = $true
        }
        else {
            Write-Host "Invalid input. Please enter a number between 1 and 120."
        }
    }
    
    Write-Host ""
    Write-Host "Parameters updated successfully!"
    Write-Host "New Settings:"
    Write-Host "Interval: $sleepSeconds seconds"
    Write-Host "Duration: $durationMinutes minutes"
    Write-Host ""
    Write-Host "Press Enter to return to the main menu..."
    Read-Host
}

# Get the user's DNS server selection
$dnsServer = (Get-DnsServerSelection).Trim()

# Initialize a hashtable to store IP address counts
$ipAddressCounts = @{}
$timestamp = Get-Date -Format "dddd M/dd/yyyy h:mm tt"
Write-Output "$timestamp" | Out-File -FilePath $logFile -Append
Write-Output "$timestamp"
Write-Output "******************************************************************************"
Write-Output "******************************************************************************" | Out-File -FilePath $logFile -Append
Write-Output "${computerName} is currently set to use ${setDNS} for DNS"
Write-Output "${computerName} is currently set to use ${setDNS} for DNS" | Out-File -FilePath $logFile -Append
$message = "Resolving $domainName by querying $dnsServer ..."
Write-Output $message.Replace("  ", " ") | Out-File -FilePath $logFile -Append
Write-Output $message.Replace("  ", " ")
Write-Output "Test Parameters: ${sleepSeconds}s interval for ${durationMinutes}m duration"
Write-Output "Test Parameters: ${sleepSeconds}s interval for ${durationMinutes}m duration" | Out-File -FilePath $logFile -Append
Write-Output "******************************************************************************"
Write-Output "*************************************************************************" | Out-File -FilePath $logFile -Append

# Run the command for the specified duration at the specified interval
$endTime = (Get-Date).AddMinutes($durationMinutes)
while ((Get-Date) -lt $endTime) {
    try {
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

        # Wait for the specified number of seconds before running the command again
        Start-Sleep -Seconds $sleepSeconds
    }
    catch {
        Write-Output "An error occurred: $_" | Out-File -FilePath $logFile -Append
        Write-Output "An error occurred: $_"
    }
}

# Print the counts of unique IP addresses
Write-Output "*************************************************************************"
Write-Output "*************************************************************************" | Out-File -FilePath $logFile -Append
Write-Output "Summary of DNS Resolutions by unique resolved IPs:" | Out-File -FilePath $logFile -Append
Write-Output "Summary of DNS Resolutions by unique resolved IPs:"
foreach ($ipAddress in $ipAddressCounts.Keys) {
    Write-Output "${ipAddress}: $($ipAddressCounts[$ipAddress])" | Out-File -FilePath $logFile -Append
    Write-Output "${ipAddress}: $($ipAddressCounts[$ipAddress])"
}
Write-Output "*************************************************************************"
Write-Output "*************************************************************************" | Out-File -FilePath $logFile -Append
Write-Output "Script completed." | Out-File -FilePath $logFile -Append
Write-Output "Script completed."
Write-Output ""
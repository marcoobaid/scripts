import os
import time
import csv
import subprocess
from collections import defaultdict

def flush_dns():
    """
    Flush the DNS resolver cache.
    """
    command = "ipconfig /flushdns >nul 2>&1"
    os.system(command)

def nslookup(domain):
    """
    Perform an nslookup for the specified domain.
    
    Args:
        domain (str): The domain to look up.
    
    Returns:
        str: The output of the nslookup command.
    """
    command = f"nslookup {domain}"
    result = subprocess.run(command, capture_output=True, text=True, shell=True)
    return result.stdout

def extract_address(nslookup_output, domain):
    """
    Extract the IP address from the nslookup output.
    
    Args:
        nslookup_output (str): The output of the nslookup command.
        domain (str): The domain that was looked up.
    
    Returns:
        str: The extracted IP address, or None if not found.
    """
    lines = nslookup_output.splitlines()
    capture = False
    for line in lines:
        if capture and "Address" in line:
            parts = line.split(":")
            if len(parts) > 1:
                return parts[1].strip()
        if domain in line:
            capture = True
    return None

def main():
    """
    Main function to perform the DNS flush, nslookup, and logging of occurrences
    over a period of 60 minutes.
    
    The function performs the following steps:
    1. Flush DNS resolver cache.
    2. Perform nslookup for the specified domain.
    3. Capture and count occurrences of the resolved IP address.
    4. Repeat the process every 60 seconds for 60 minutes.
    5. Generate a CSV report with the address occurrences.
    6. Print a summary of the results.
    """
    domain = "athenanet.athenahealth.com"
    duration = 60 * 60  # 60 minutes
    interval = 60  # 60 seconds
    occurrences = defaultdict(int)
    start_time = time.time()
    attempt = 1
    
    while time.time() - start_time < duration:
        flush_dns()
        nslookup_output = nslookup(domain)
        address = extract_address(nslookup_output, domain)
        if address:
            occurrences[address] += 1
            print(f"Attempt {attempt}, {domain} resolved to {address}")
        else:
            print(f"Attempt {attempt}, failed to resolve {domain}")
        attempt += 1
        time.sleep(interval)
    
    with open("nslookup_report.csv", "w", newline="") as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(["address", "occurrence"])
        for address, count in occurrences.items():
            csvwriter.writerow([address, count])
    
    print("Report generated: nslookup_report.csv")
    print("\n==========================")
    print("Summary of Athena Lookup")
    print("==========================")
    for address, count in occurrences.items():
        print(f"{address} resolved {count} times")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Backup Script with Multiprocessing
----------------------------------

This script is designed to efficiently back up data from the source directory
(/data/prod) to the destination directory (/data/prod_backup) using the rsync
command. It utilizes the multiprocessing module to parallelize the syncing
tasks, improving performance by leveraging multiple CPU cores.

Modules:
    - os: Provides functions for interacting with the operating system.
    - subprocess: Allows you to spawn new processes, connect to their input/output/error pipes, and obtain their return codes.
    - multiprocessing: Supports spawning processes using an API similar to the threading module.

Functions:
    - sync_task: Synchronizes a single source file or directory to the destination using rsync.
    - main: Main function that prepares the list of tasks and distributes them among worker processes for parallel execution.

Usage:
    Run this script with elevated permissions (e.g., sudo) if necessary to
    ensure it has access to the source and destination directories:
    
    $ sudo ./backup_script.py

Author:
    Your Name
"""

import os
import subprocess
from multiprocessing import Pool, cpu_count

def sync_task(task):
    """
    Synchronizes a single source file or directory to the destination using rsync.
    
    Args:
        task (tuple): A tuple containing the source path and the destination path.
    
    Returns:
        None
    """
    src_path, dest_path = task
    try:
        subprocess.run(['rsync', '-arq', src_path, dest_path], check=True)
        print(f"Successfully synced {src_path} to {dest_path}")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while syncing {src_path} to {dest_path}: {e}")

def main():
    """
    Main function that prepares the list of tasks and distributes them among worker processes for parallel execution.
    
    Steps:
        1. Define the source and destination directories.
        2. Create the destination directory if it doesn't exist.
        3. Traverse the source directory and create a list of tasks for each file and directory.
        4. Use a pool of worker processes to execute the sync_task function in parallel across all tasks.
    
    Returns:
        None
    """
    src = "/data/prod"
    dest = "/data/prod_backup"

    # Create destination directory if it doesn't exist
    if not os.path.exists(dest):
        os.makedirs(dest)

    # Create a list of tasks for each file and directory in the source directory
    tasks = []
    for root, dirs, files in os.walk(src):
        for name in dirs + files:
            src_path = os.path.join(root, name)
            dest_path = os.path.join(dest, os.path.relpath(src_path, src))
            tasks.append((src_path, dest_path))
    
    # Use available CPU cores to parallelize the task
    with Pool(cpu_count()) as pool:
        pool.map(sync_task, tasks)
        pool.close()
        pool.join()

if __name__ == "__main__":
    main()


"""
Description:
sync_task Function:

This function synchronizes a single file or directory from the source to the destination using the rsync command.

It takes a task tuple as an argument, which contains the source path and the destination path.

main Function:

Defines the source (src) and destination (dest) directories.

Creates the destination directory if it doesn’t already exist.

Uses os.walk() to traverse the source directory and create a list of tasks. Each task is a tuple representing the source and destination paths.

Utilizes the multiprocessing.Pool class to create a pool of worker processes, distributing the tasks among the available CPU cores for parallel execution.

"""
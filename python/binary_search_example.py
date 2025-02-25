"""
find_item.py

This script defines a function `find_item` that performs a binary search on a sorted list
to determine if a specific item is present in the list. The script also includes example
usage of the `find_item` function with a list of names.

Functions:
    def find_item(list, item):
        Ensures the list is sorted and performs a binary search to find the item.
        Args:
            list (list): The list of items to search.
            item (any): The item to find in the list.
        Returns:
            bool: True if the item is found in the list, False otherwise.

Example Usage:
    list_of_names = ["Parker", "Drew", "Cameron", "Logan", "Alex", "Chris", "Terry", "Jamie", "Jordan", "Taylor"]

    print(find_item(list_of_names, "Alex"))   # True
    print(find_item(list_of_names, "Andrew")) # False
    print(find_item(list_of_names, "Drew"))   # True
    print(find_item(list_of_names, "Jared"))  # False
"""

def find_item(list, item):
    # Ensure the list is sorted before performing binary search
    list.sort()
    #print(f"Sorted list: {list}")

    # Returns True if the item is in the list, False if not.
    if len(list) == 0:
        return False

    # Is the item in the center of the list?
    middle = len(list) // 2
    #print(f"Checking middle index: {middle}, middle item: {list[middle]}")
    if list[middle] == item:
        return True

    # Is the item in the first half of the list?
    if item < list[middle]:
        # Call the function with the first half of the list
        #print("Checking the left half")
        return find_item(list[:middle], item)
    else:
        # Call the function with the second half of the list
        #print("Checking the right half")
        return find_item(list[middle + 1:], item)

    return False

list_of_names = ["Parker", "Drew", "Cameron", "Logan", "Alex", "Chris", "Terry", "Jamie", "Jordan", "Taylor"]

print(find_item(list_of_names, "Alex"))   # True
print(find_item(list_of_names, "Andrew")) # False
print(find_item(list_of_names, "Drew"))   # True
print(find_item(list_of_names, "Jared"))  # False

"""
find_item_in_list.py

This script checks if an item is in a list and returns its presence and position.

Functions:
    def find_item_in_list(lst, item):
        Args:
            lst (list): The list to search.
            item (any): The item to find.
        Returns:
            str: Message indicating the item's presence and position.

Example Usage:
    list_of_names = ['Parker', 'Drew', 'Cameron', 'Logan', 'Alex', 'Chris', 'Terry', 'Jamie', 'Jordan', 'Taylor']
    look_for = input("Enter the name you are looking for: ")
    print(find_item_in_list(list_of_names, look_for))
"""

def find_item_in_list(lst, item):
    if item not in lst:
        return "{} is not in the given list.".format(item)
    else:
        return "{} is in the given list at position {}.".format(item, lst.index(item) + 1)

list_of_names = ['Parker', 'Drew', 'Cameron', 'Logan', 'Alex', 'Chris', 'Terry', 'Jamie', 'Jordan', 'Taylor']
look_for = input("Enter the name you are looking for: ")

result = find_item_in_list(list_of_names, look_for)
print(result)

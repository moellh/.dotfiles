################################################################################
# Script to remove latest ObsidianMD vault.
# 
# - I use this scipt before starting Obsidian to avoid auto-opening the 
#   latest vault.
# - Simply removes text ',"open":true' from the obsidian.json file.
# - Contents of scripts were autogenerated by ChatGPT.
################################################################################

import os

def remove_text_from_file(filename, text_to_remove):
    try:
        with open(filename, 'r') as file:
            lines = file.readlines()

        with open(filename, 'w') as file:
            for line in lines:
                # Remove the text if it exists in the line
                modified_line = line.replace(text_to_remove, '')
                file.write(modified_line)

        print(f"Removed '{text_to_remove}' from {filename}")

    except FileNotFoundError:
        print(f"File '{filename}' not found.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    home = os.path.expanduser("~")
    filename = f"{home}/.config/obsidian/obsidian.json"
    text_to_remove = ',"open":true'

    remove_text_from_file(filename, text_to_remove)

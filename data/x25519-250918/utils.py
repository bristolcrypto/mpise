# file: utils.py

# This file requires the 'colorama' package.
# Install it with: pip install colorama
from colorama import Fore, Style, init

# Initialize colorama once in the module where the function is defined
init(autoreset=True)

def printd(message, level='info'):
    """
    Custom print function for different message levels.
    'info' -> Green (can be used for success messages)
    'warning' -> Yellow
    'error' -> Red
    """
    # A more scalable way using a dictionary
    level_map = {
        'info': Fore.GREEN,
        'warning': Fore.YELLOW,
        'error': Fore.RED,
    }
    
    # Get the color for the level, default to green if not found
    color = level_map.get(level, Fore.GREEN)
    
    # Format the message
    prefix = f"[{level.upper()}]"
    print(color + Style.BRIGHT + f"{prefix:<10} {message}")

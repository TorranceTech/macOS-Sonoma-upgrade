#!/bin/bash

# Set the deferral time in seconds (1 hour = 3600 seconds)
deferral_time=3600

# Prompt the user with a dialog box for the password
password=$(osascript -e 'Tell application "System Events" to display dialog "Please enter your password to install the macOS update." default answer "" with hidden answer buttons {"OK"} default button "OK"' -e 'text returned of the result')

# Check if the user provided a password
if [ -n "$password" ]; then
    # Prompt the user with a dialog box for the update choice
    button_clicked=$(osascript -e 'Tell application "System Events" to choose from list {"Install Now", "Defer for 1 hour"} with title "macOS Update" with prompt "A macOS update is available. Please choose an option:" default items {"Install Now"} without multiple selections allowed and empty selection allowed')

    # Check the user's choice
    if [ "$button_clicked" == "Install Now" ]; then
        # User chose "Install Now," so execute the update immediately
        echo "Installing macOS update..."
        echo "$password" | sudo -S /usr/sbin/softwareupdate -i 'macOS Sonoma 14.5'

        # Check if the update was successful
        if [ $? -eq 0 ]; then
            echo "The update has been installed successfully."
            # Prompt for restart
            button_restart=$(osascript -e 'Tell application "System Events" to display dialog "The update has been installed. Would you like to restart now?" buttons {"Restart Now", "Later"} default button "Restart Now"')

            if [ "$button_restart" == "Restart Now" ]; then
                # User chose to restart, so execute the restart
                sudo /sbin/reboot
            else
                echo "User chose to restart later."
            fi
        else
            echo "Failed to install the update."
        fi
    elif [ "$button_clicked" == "Defer for 1 hour" ]; then
        # User chose "Defer," so wait for the deferral time
        echo "Deferring macOS update for 1 hour..."
        sleep $deferral_time
        # The script can be run again after the deferral time
    else
        echo "No valid option selected. Exiting without performing the update."
    fi
else
    echo "Password not provided. Exiting without performing the update."
fi

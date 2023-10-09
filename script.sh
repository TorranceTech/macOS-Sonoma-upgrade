#!/bin/bash

# Set the deferral time in seconds (1 hour = 3600 seconds)
deferral_time=3600

# Prompt the user with a dialog box for password
password=""

while [ -z "$password" ]; do
    # Prompt the user with a dialog box for password
    password=$(osascript -e 'tell app "System Events" to display dialog "Please enter your password to install the macOS update." default answer "" with hidden answer buttons {"OK"} default button "OK"')

    if [ -z "$password" ]; then
        # If the user didn't provide a password, show an error dialog
        osascript -e 'tell app "System Events" to display dialog "Password is required. Please try again." buttons {"OK"} default button "OK"'
    fi
done

# Check if the user provided a password
if [ -n "$password" ]; then
    # Prompt the user with a dialog box for the update choice
    button_clicked=$(osascript -e "tell app \"System Events\" to choose from list {\"Install Now\", \"Defer for 1 hour\"} with title \"macOS Update\" with prompt \"A macOS update is available. Please choose an option:\" default items {\"Install Now\"} without multiple selections allowed and empty selection allowed")

    # Check the user's choice
    if [ "$button_clicked" == "Install Now" ]; then
        # User chose "Install Now," so execute the update immediately without sudo
        echo "Installing macOS update..."
        /usr/sbin/softwareupdate -i 'macOS Sonoma 14.0-23A344'

        # Echo the dialog box content
        echo "User chose to Install Now: A macOS update is available."
        
        # Prompt for restart
        button_restart=$(osascript -e 'tell app "System Events" to display dialog "The update has been installed. Would you like to restart now?" buttons {"Restart Now", "Later"} default button "Restart Now"')

        if [ "$button_restart" == "Restart Now" ]; then
            # User chose to restart, so execute restart with sudo
            echo "$password" | sudo -S /sbin/reboot
        else
            echo "User chose to restart later."
        fi
    elif [ "$button_clicked" == "Defer for 1 hour" ]; then
        # User chose "Defer," so wait for the deferral time
        echo "Deferring macOS update for 1 hour..."
        sleep $deferral_time

        # Prompt the user with a dialog box for the update choice after deferral
        button_clicked=$(osascript -e "tell app \"System Events\" to display dialog \"The deferral time has passed. Would you like to install the macOS update now?\" buttons {\"Install Now\", \"Defer for 1 hour\"} default button \"Install Now\" giving up after $deferral_time")

        if [ "$button_clicked" == "Install Now" ]; then
            # User chose "Install Now" after the deferral, so execute the update immediately without sudo
            echo "Now installing macOS update..."
            /usr/sbin/softwareupdate -i 'macOS Sonoma 14.0-23A344'

            # Echo the dialog box content
            echo "User chose to Install Now: A macOS update is available."
            
            # Prompt for restart
            button_restart=$(osascript -e 'tell app "System Events" to display dialog "The update has been installed. Would you like to restart now?" buttons {"Restart Now", "Later"} default button "Restart Now"')

            if [ "$button_restart" == "Restart Now" ]; then
                # User chose to restart, so execute restart with sudo
                echo "$password" | sudo -S /sbin/reboot
            else
                echo "User chose to restart later."
            fi
        else
            echo "User chose to Defer again. Exiting."
        fi
    else
        echo "No valid option selected. Exiting without performing the update."
    fi
else
    echo "Password not provided. Exiting without performing the update."
fi



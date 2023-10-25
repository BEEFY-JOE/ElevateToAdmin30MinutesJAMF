#!/bin/bash

###############################################
# This script will provide temporary admin    #
# rights to a standard user right from self   #
# service. First, it will grab the username   #
# of the logged-in user, elevate them to admin#
# and then create a launch daemon that will   #
# count down from 30 minutes and then create  #
# and run a secondary script that will demote #
# the user back to a standard account. The    #
# launch daemon will continue to count down   #
# no matter how often the user logs out or    #
# restarts their computer.                    #
###############################################

#############################################
# Check if parameter $3 is passed and set   #
#############################################

if [ -z "$3" ]; then
    echo "Error: No user specified. \$3 is empty. Exiting."
    exit 1
fi

echo $3

# Display the dialog with a 60-second timeout
userChoice=$(osascript -e 'display dialog "You will be granted administrative rights for 30 minutes, after which you will be reverted to a standard user. Activity during this period will be logged. Please use this privilege responsibly. If you do not click '"'"'Agree'"'"' within 60 seconds, you will remain a standard user." buttons {"Agree"} default button 1 giving up after 60')

# Check if the user agreed or the dialog timed out
if [[ $userChoice == *"Agree"* ]]; then
    echo "User agreed to admin elevation."
else
    echo "User did not confirm admin elevation or time expired. Exiting."
    exit 1
fi

#########################################################
# Write a daemon that will let you remove the privilege #
# with another script, then load the daemon             #
#########################################################

# Path to the LaunchDaemon plist
launchDaemonPath="/Library/LaunchDaemons/removeAdmin.plist"

# Check if the LaunchDaemon plist already exists, and if so, bootout and remove it
if [ -f "$launchDaemonPath" ]; then
    launchctl bootout system/removeAdmin
    rm -f "$launchDaemonPath"
fi

# Create the LaunchDaemon plist using PlistBuddy
/usr/libexec/PlistBuddy \
    -c "Add :Label string removeAdmin" \
    -c "Add :ProgramArguments array" \
    -c "Add :ProgramArguments:0 string /bin/bash" \
    -c "Add :ProgramArguments:1 string /Library/Application Support/JAMF/removeAdminRights.sh" \
    -c "Add :RunAtLoad bool true" \
    -c "Add :StartInterval integer 1800" \
    "$launchDaemonPath"

# Set ownership and permissions
chown root:wheel "$launchDaemonPath"
chmod 644 "$launchDaemonPath"

# Bootstrap the daemon 
launchctl bootstrap system "$launchDaemonPath"
sleep 10

#########################
# Make file for removal #
#########################

if [ ! -d /private/var/userToRemove ]; then
    mkdir /private/var/userToRemove
    echo $3 | tee /private/var/userToRemove/user
else
    echo $3 | tee -a /private/var/userToRemove/user
fi

##################################
# Give the user admin privileges #
##################################

/usr/sbin/dseditgroup -o edit -a $3 -t user admin

########################################
# Write a script for the launch daemon #
# to run to demote the user back and   #
# then pull logs of what the user did. #
########################################

# Define the path for the removal script
removalScriptPath="/Library/Application Support/JAMF/removeAdminRights.sh"

# If the removal script already exists, delete it before proceeding
if [ -f "$removalScriptPath" ]; then
    echo "Old removal script found. Deleting..."
    rm -f "$removalScriptPath"
fi

# Now, create the new removal script
cat << 'EOF' | tee "$removalScriptPath"
#!/bin/bash

if [ -f /private/var/userToRemove/user ]; then
    userToRemove=$(cat /private/var/userToRemove/user)
    echo "Removing $userToRemove's admin privileges"
    /usr/sbin/dseditgroup -o edit -d "$userToRemove" -t user admin
    rm -f /private/var/userToRemove/user

    # Define a log file location
    logFile="/private/var/userToRemove/scriptActivity.log"

    # Get the current time in UTC
    currentTime=$(date -u +"%Y-%m-%d_%H-%M-%S")

    # Cleanup old logarchive tarballs older than 6 months
    find /private/var/userToRemove/ -name "*.tar.gz" -type f -mtime +180 -exec rm {} \;

    # Collect logs and apply the current time to the log archive's name
    log collect --last 30m --output "/private/var/userToRemove/${userToRemove}_UTC_${currentTime}.logarchive"

    # Compress the collected log file
    tar -czf "/private/var/userToRemove/${userToRemove}_UTC_${currentTime}.logarchive.tar.gz" -C "/private/var/userToRemove" "${userToRemove}_UTC_${currentTime}.logarchive"

    # Remove the original uncompressed logarchive
    rm -rf "/private/var/userToRemove/${userToRemove}_UTC_${currentTime}.logarchive"

    # Clean up
    launchDaemonPath="/Library/LaunchDaemons/removeAdmin.plist" 
    rm "$launchDaemonPath"
    rm -- "$0"

    # Properly terminate the LaunchDaemon session
    launchctl bootout system/removeAdmin
fi
EOF

chmod +x "$removalScriptPath"

exit 0

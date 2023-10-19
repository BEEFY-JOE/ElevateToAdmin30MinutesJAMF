This is a fork of MakeMeAnAdmin at https://github.com/jamf/MakeMeAnAdmin

Problems with the original script is that it had not been updated in 5 years. Apple is depricating bash and the original script uses bash. This script has been rewritten to remove bashisms and use POSIX compliant shell, to make it future proof. The $userToRemove.logarchive file was not being written at the exit of the script, resulting in nothing being logged during the time the user was an admin, which is a security risk as there is not review mechanism for knowing what they did while they were an admin. The last thing that was changed was to leverage JAMF's usage of prefilled script parameters, parameter $3 is the currently logged in user, so I replaced the sections where we grb the currently logged in username, with the $3 parameter to add consistency for my fellow JAMF admins. 

----------------------------------------------------------------------------------

Make Me an Admin!

This script, when run, will allow a standard user to upgrade themselves to an admin for 30 minutes and then will grab a snapshot of the logs for the past 30 minutes as well so you can track what they did. 

The script will create a launch daemon to take care of demoting the user so that no matter how many times they log out or shut down, after 30 minutes of uptime, a script will be run to remove their admin privileges. 

It is recommended to push this script as a policy to self service to run only once per day.

Edits: If you wish to tailor the script to your own needs, here is where to make the changes.

User Prompt: Line 24 | Plain text
Default Message: You now have administrative rights for 30 minutes. DO NOT ABUSE THIS PRIVILEGE... 
Default Button: "Make me an admin, please!"

Time Frame for Admin Rights: Line 39 | Integer in seconds
Default: 1800 (30 minutes)

Time Frame for logs to be pulled:  Line 82 | String after the "--last" flag in minutes
Default: 30m

Location to save logs: line 82 | String after "--output" flag, must be valid directory
Default: /private/var/userToRemove/$userToRemove.logarchive

This is a fork of MakeMeAnAdmin at https://github.com/jamf/MakeMeAnAdmin

This document discusses the modernization of a macOS script designed explicitly for use with JAMF Self Service. The script grants temporary admin rights to users. The original script, last updated five years ago, contained outdated commands and lacked several essential features ensuring optimal security and user experience. Here, we'll outline the changes made and the benefits of the updated script.

Changes Made
1. Updated macOS Commands:
The old script used legacy macOS commands, which might not be compatible with newer macOS versions. Apple has since introduced newer commands for managing services.

Old Commands:

launchctl load
launchctl unload
New Commands:

launchctl bootstrap
launchctl bootout

2. Enhanced Logging:
The new script ensures that all administrative activities performed by the temporarily elevated user are logged and stored securely. Furthermore, the logs are compressed for space efficiency, and older logs are automatically cleaned up after six months.

3. Improved Cleanup:
The script has been enhanced to ensure that any old instances of the LaunchDaemon and the removeAdmin script are correctly identified and removed. This change prevents any clutter or potential conflicts with older versions.

4. User Confirmation:
In the old script, admin rights were granted without explicit user agreement. Now, a dialog is presented to the user, asking them to agree to the temporary admin elevation. If the user doesn't confirm within 60 seconds, the script will not elevate their privileges. This step ensures that the user is aware of the action and the associated responsibilities.

Conclusion
The new script, tailored for JAMF Self Service, offers a safer, more efficient, and user-friendly approach to granting temporary admin rights. It uses modern macOS commands, incorporates enhanced logging, and ensures that old data and scripts are properly cleaned up. Moreover, it seeks user confirmation before proceeding, ensuring the user is always in control and aware of their actions within the JAMF environment.

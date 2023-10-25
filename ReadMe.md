# Temporary Admin Rights for JAMF Self Service

This script offers a streamlined and secure method for granting users temporary administrative rights through the JAMF Self Service. With a strong emphasis on modern command structures, precise logging, efficient cleanup, and user interaction, it provides an effective solution for administrators who want to empower their users temporarily without compromising system integrity.

## Description

Originally based on a script that was last updated five years ago, this revised version introduces significant enhancements:

1. **Modern Command Implementation**: Deprecated commands (`load` & `unload`) have been replaced with their contemporary counterparts (`bootstrap` & `bootout`), ensuring compatibility with the latest macOS versions.
  
2. **User Confirmation**: Before administrative rights are granted, users are presented with a confirmation dialog. This step ensures that users are consciously accepting the elevated permissions and are aware of the associated responsibilities.
  
3. **Efficient Logging**: The script incorporates a robust logging system that captures all administrative actions performed during the temporary admin session. For optimal storage, the logs are compressed, and older archives are automatically purged after six months.
  
4. **Thorough Cleanup**: All residues from previous script runs, such as lingering LaunchDaemons and the `removeAdmin` script, are diligently identified and removed. This cleanup process ensures a clean and conflict-free system environment.
  
5. **Direct User Identification**: The revised script accepts the username directly as a parameter, eliminating any inaccuracies or inconsistencies that might arise from the older `who` command.

## Credits

This modernization effort has been a collaborative initiative. Special thanks to:

- **Pico** from MacAdmins Slack for invaluable insights and guidance throughout the process.

## Usage

This script is designed explicitly for integration with JAMF Self Service. To deploy:

1. Ensure the JAMF Self Service is correctly set up in your environment.
2. Add the script to your JAMF Self Service policies.
3. Define the necessary parameters and triggers.
4. Deploy to target machines.

**Note**: Always test scripts in a controlled environment before rolling out to production systems.

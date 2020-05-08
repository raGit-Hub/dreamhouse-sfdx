//deploy.bat
@ECHO OFF
# Read the scratch org username from file created in prior stage
- export SCRATCH_ORG_USERNAME=`cat ./SCRATCH_ORG_USERNAME.TXT`
- echo $SCRATCH_ORG_USERNAME
# Authenticate with your playground or sandbox environment
- sfdx force:auth:jwt:grant --setdefaultdevhubusername --clientid $SF_CONSUMER_KEY --jwtkeyfile assets/server.key --username $SF_USERNAME
- sfdx force:config:set defaultusername=$SF_USERNAME
# Delete Scratch Org that you were inspecting from your browser
- sfdx force:data:record:delete --sobjecttype ScratchOrgInfo --where "SignupUsername='$SCRATCH_ORG_USERNAME'"
# Read the package version id from file created in prior stage
- export PACKAGE_VERSION_ID=`cat ./PACKAGE_VERSION_ID.TXT`
- echo $PACKAGE_VERSION_ID
# Promote the package version
- sfdx force:package:version:promote --package $PACKAGE_VERSION_ID --noprompt
# Install the package version
- sfdx force:package:install --package $PACKAGE_VERSION_ID --wait 10 --publishwait 10 --noprompt
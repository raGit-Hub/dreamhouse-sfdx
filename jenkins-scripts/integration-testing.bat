//integration-testing.bat
@ECHO OFF
# Authenticate to the Dev Hub using the server key
- sfdx force:auth:jwt:grant --setdefaultdevhubusername --clientid $SF_CONSUMER_KEY --jwtkeyfile assets/server.key --username $SF_USERNAME
# Create scratch org
- sfdx force:org:create --setdefaultusername --definitionfile config/project-scratch-def.json --wait 10 --durationdays 7
- sfdx force:org:display
# Increment package version number
- echo $PACKAGE_NAME
- PACKAGE_VERSION_JSON="$(eval sfdx force:package:version:list --concise --released --packages $PACKAGE_NAME --json | jq '.result | sort_by(-.MajorVersion, -.MinorVersion, -.PatchVersion, -.BuildNumber) | .[0] // ""')"
- echo $PACKAGE_VERSION_JSON
- IS_RELEASED=$(jq -r '.IsReleased?' <<< $PACKAGE_VERSION_JSON)
- MAJOR_VERSION=$(jq -r '.MajorVersion?' <<< $PACKAGE_VERSION_JSON)
- MINOR_VERSION=$(jq -r '.MinorVersion?' <<< $PACKAGE_VERSION_JSON)
- PATCH_VERSION=$(jq -r '.PatchVersion?' <<< $PACKAGE_VERSION_JSON)
- BUILD_VERSION="NEXT"
- if [ -z $MAJOR_VERSION ]; then MAJOR_VERSION=1; fi;
- if [ -z $MINOR_VERSION ]; then MINOR_VERSION=0; fi;
- if [ -z $PATCH_VERSION ]; then PATCH_VERSION=0; fi;
- if [ "$IS_RELEASED" == "true" ]; then MINOR_VERSION=$(($MINOR_VERSION+1)); fi;
- VERSION_NUMBER="$MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION.$BUILD_VERSION"
- echo $VERSION_NUMBER
# Create packaged version
- export PACKAGE_VERSION_ID="$(eval sfdx force:package:version:create --package $PACKAGE_NAME --versionnumber $VERSION_NUMBER --installationkeybypass --wait 10 --json | jq -r '.result.SubscriberPackageVersionId')"
# Save your PACKAGE_VERSION_ID to a file for later use during deploy so you know what version to deploy
- echo "$PACKAGE_VERSION_ID" > PACKAGE_VERSION_ID.TXT
- echo $PACKAGE_VERSION_ID
# Install package in DevHub org (this is a compiled library of the app)
- sfdx force:package:list
- sfdx force:package:install --package $PACKAGE_VERSION_ID --wait 10 --publishwait 10 --noprompt
# Assign DreamHouse permission set to scratch org default user
- sfdx force:user:permset:assign --permsetname DreamHouse
# Add sample data into app
- sfdx force:data:tree:import --plan data/sample-data-plan.json
# Run unit tests in scratch org
- sfdx force:apex:test:run --wait 10 --resultformat human --codecoverage --testlevel RunLocalTests
# Get the username for the scratch org
- export SCRATCH_ORG_USERNAME="$(eval sfdx force:user:display --json | jq -r '.result.username')"
- echo "$SCRATCH_ORG_USERNAME" > ./SCRATCH_ORG_USERNAME.TXT
# Generate a new password for the scrach org
- sfdx force:user:password:generate
- echo -e "\n\n\n\n"
# Display username, password, and instance URL for login
# Be careful not to do this in a publicly accessible pipeline as it exposes the credentials of your scratch org
- sfdx force:user:display
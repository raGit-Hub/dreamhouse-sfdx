//code-testing.bat
@ECHO OFF
# Authenticate to the Dev Hub using the server key
- sfdx force:auth:jwt:grant --setdefaultdevhubusername --clientid $SF_CONSUMER_KEY --jwtkeyfile assets/server.key --username $SF_USERNAME
# Create scratch org
- sfdx force:org:create --setdefaultusername --definitionfile config/project-scratch-def.json --wait 10 --durationdays 7
- sfdx force:org:display
# Push source to scratch org (this is with source code, all files, etc)
- sfdx force:source:push
# Assign DreamHouse permission set to scratch org default user
- sfdx force:user:permset:assign --permsetname DreamHouse
# Add sample data into app
- sfdx force:data:tree:import --plan data/sample-data-plan.json
# Unit Testing
- sfdx force:apex:test:run --wait 10 --resultformat human --codecoverage --testlevel RunLocalTests
# Delete Scratch Org
- sfdx force:org:delete --noprompt
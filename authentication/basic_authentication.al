#-----------------------------------------------------------------------------------------------------------------------
# Declare username and password authentication for a node - this is used for REST authentication
# :cURL example:
# curl -X GET http://10.10.1.1:32049 \
#   -H "command: get status" \
#   -H "User-Agent: AnyLog/1.23" \
#   -u ${USERNAME}:${PASSWORD} \
#   -w "\n"
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/authentication/basic_authentication.al
on error ignore
if !debug_mode.int == 1 then set debug on
else if !debug_mode.int == 2 then set debug interactive

:validate-params:
if !debug_mode.int > 0 then print "Validate params needed for authentication"

if not !username then
do print "Missing user to be used for REST authentication, cannot setup authentication"
do goto disable-authentication

if not !user_password then
do print "Missing password associated with user to be used for REST authentication, cannot setup authentication"
do goto disable-authentication

:enable-authentication:
if !debug_mode.int > 0 then print "Enable authentication"
on error goto enable-authentication-error
set user authentication on

:create-user:
if !debug_mode.int > 0 then print "Create a new user for the node"
on error goto create-user-error
id add user where name = !username and password = !user_password

:end-script:
end script

:disable-authentication:
set enable_auth = false
set authentication off
goto end-script

:create-user-error:
print "Failed to create user, cannot enable authentication"
goto disable-authentication

:enable-authentication-error:
print "Failed to enable user authentication, cannot enable authentication"
goto disable-authentication
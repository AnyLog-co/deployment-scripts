#-----------------------------------------------------------------------------------------------------------------------
# Create password for node and enable authentication
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/authentication/enable_authentication.al
on error ignore
if !debug_mode.int == 1 then set debug on
else if !debug_mode.int == 2 then set debug interactive

:validate-params:
if !debug_mode.int > 0 then print "Validate params needed for authentication"

if not !node_password then
do print "Missing node specific password, cannot set authentication"
do goto disable-authentication

:set-password:
if !debug_mode.int > 0 then print "Set password for node"

on error goto set-password-error
set local password = !node_error

# :enable-authentication:
# if !debug_mode.int > 0 then print "Enable authentication"

# on error goto enable-authentication-error
# set authentication on

:end-script:
end script

:disable-authentication:
set enable_auth = false
set authentication off
goto end-script

:set-password-error:
print "Failed to password for node, cannot enable authentication"
goto disable-authentication

:enable-authentication-error:
print "Failed to enable authentication
goto disable-authentication

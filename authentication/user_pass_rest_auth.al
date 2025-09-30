#----------------------------------------------------------------------------------------------------------------------
# Script for setting username / passord based REST authentication
# :sample-curl:
# curl -X GET http://10.10.1.1:32049 \
#   -H "command: get status" \
#   -H "User-Agent: AnyLog/1.23" \
#   -u ${USERNAME}:${PASSWORD} \
#   -w "\n"
#-----------------------------------------------------------------------------------------------------------------------
# process deployment-scripts/authentication/user_pass_rest_auth.al

on error ignore
:auth-params:
if $LOCAL_PASS then local_pass = $LOCAL_PASS
if $AUTH_USER then auth_user = $AUTH_USER
if $AUTH_PASS then auth_pass = $AUTH_PASS
if $AUTH_TYPE then set auth_type = $AUTH_TYPE
if not !local_pass then missing-local-pass
if not !auth_user or not !auth_pass then goto missing-auth-params
if !auth_type != admin and !auth_type != user then set auth_type = user

:set-local-pass:
on error goto local-pass-error
set local password = !local_pass

:enable-user-auth:
on error goto user-auth-error
set user authentication on

:create-user:
on error goto create-user-error
<id add user where
    name = !auth_user and
    password = !auth_pass and
    type = !auth_type
>

:end-script:
end script

:missing-local-pass:
print "Missing local password"
goto end-script

:missing-auth-params:
print "Missing user or password for authentication"
goto end-script

:local-pass-error:
print "Failed to set local password"
goto end-script

:create-user-error:
print "Failed to create user"
goto end-script

 :user-auth-error:
 print "Failed to enable user authentication"

#-----------------------------------------------------------------------------------------------------------------------
# Using !node_password - create CA authentication certificates
# :File location:
#   -> AnyLog-Network/data/ca-new-company-private-key.key
#   -> AnyLog-Network/data/ca-new-company-private-key.crt
#-----------------------------------------------------------------------------------------------------------------------
# process !anylog_path/deployment-scripts/authentication/ca_key_authentication.al
on error ignore

if !debug_mode.int == 1 then set debug on
else if !debug_mode.int == 2 then set debug interactive

:validate-params:
if !debug_mode.int > 0 then print "Validate params exist"
if not !hostname then hostname = get hostname


:create-ca-cert:
if !debug_mode.int > 0 then print "Create CA certificates"
on error goto create-ca-cert-error
if !country and !state and !city then
<do id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname and
    country=!country and
    state=!state and
    locality=!city>
else if !country and !state and not !city then
<do id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname and
    country=!country and
    state=!state>
else if !country and not !state and !city then
<do id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname and
    country=!country and
    locality=!city>
else if not !country and !state and !city then
<do id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname and
    state=!state and
    locality=!city>
else if !country and not !state and not !city then
<do id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname and
    country=!country>
else if not !country and !state and not !city then
<do id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname and
    locality=!city>
else if not !country and not !state and !city then
<do id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname and
    state=!state and
    locality=!city>
<else id generate certificate authority where
    password=!node_password and
    org = !company_name and
    hostname=!hostname>

:end-script:
end script

:disable-authentication:
set enable_auth = false
set authentication off
goto end-script

:create-ca-cert-error:
print "Failed to create CA authentication keys"
goto disable-authentication

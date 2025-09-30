#----------------------------------------------------------------------------------------------------------------------#
# The following provides a sample script for utilizing OpenBao to declare params.
# The sample only connect to a TCP and REST connection
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/demo-scripts/openbao_demo

:prepare:
on error ignore
set authentication off

# directory where deployment-scripts is stored
set anylog_path = /app
if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH

set anylog home !anylog_path

local_scripts = !anylog_path/deployment-scripts/node-deployment
test_dir = !anylog_path/deployment-scripts/test
if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
if $TEST_DIR then set test_dir = $TEST_DIR

create work directories
system touch !blockchain_file

:openboa-params:
openbao_url = http://0.0.0.0:8200
if $OPENBAO_VAULT_IP then set openbao_url = $OPENBAO_VAULT_IP

if not $OPENBAO_VAULT_TOKEN then goto missing-openbao-token
openbao_token = $OPENBAO_VAULT_TOKEN

if not $SECTION_NAME then goto missing-section-name
section_name = $SECTION_NAME

:openbao-status:
# check OpenBao status
on error goto openbao-status-error
<openbao_status = rest get where
    url=!openbao_url/v1/sys/health and
    X-Vault-Token=!openbao_token and
    Content-Type=application/json>

print !openbao_status

:openbao-params:
on error goto openbao-params-error
<opennbao_params = rest get where
    url=!openbao_url/v1/secret/data/!section_name and
    X-Vault-Token=!openbao_token>

:set-params:
on error ignore

set node name !section_name

anylog_server_port = from !opennbao_params bring [data][data][!section_name][SERVICE_PORT]
tcp_bind = from !opennbao_params bring [data][data][!section_name][TCP_BIND]
tcp_threads = from !opennbao_params bring [data][data][!section_name][TCP_THREADS]

anylog_rest_port = from !opennbao_params bring [data][data][!section_name][REST_PORT]
rest_bind = from !opennbao_params bring [data][data][!section_name][REST_BIND]
rest_timeout = from !opennbao_params bring [data][data][!section_name][REST_TIMEOUT]
rest_threads =  from !opennbao_params bring [data][data][!section_name][REST_THREADS]

:connect-network:
process !local_scripts/connect_networking.al

:get-process:
get processes

:end-script:
end script

:terminate-scripts:
exit scripts

:missing-openbao-token:
print "Missing OpenBao Token, cannot continue"
goto terminate-scripts

:missing-section-name:
print "Missing OpenBao secret section, cannot continue..."
goto terminate-scripts

:openbao-status-error:
print "Failed to get OpenBao status"
goto terminate-scripts

:openbao-params-error:
print "Failed to get params from OpenBao"
goto terminate-scripts
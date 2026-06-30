#----------------------------------------------------------------------------------------------------------------------#
# Sample deployment process for OPC-UA
# https://github.com/AnyLog-co/documentation/blob/master/opcua.md
# :steps:
#   3. create OPC-UA call
#   4. start OPC-UA service
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/connectors/opcua_client.al

:check-vars:
on error ignore
if not !opcua_url then goto missing-opcua-url
if not !opcua_node then goto missing-opcua-node
if not !opcua_frequency then opcua_frequency = 1


:opcua-service:
on error goto opcua-service-error
<get opcua struct where
    url = !opcua_url and
    node = !opcua_node and
    dbms = !default_dbms and
    frequency = !opcua_frequency and
    format = run_client  and
    class = variable and
    name=opcua-client1 and
    output = !tmp_dir/run_opcua_service.al>

on error ignore
process !tmp_dir/run_opcua_service.al

get plc client

:end-script:
end script

:missing-opcua-url:
print "Missing OPC-UA URL cannot declare OPC-UA"
goto end-script

:missing-opcua-node:
print "Missing OPC-UA node ID(s) cannot declare OPC-UA"
goto end-script

:opcua-service-error:
print "Failed to start OPC-UA service"
goto end-script

#---------------------------------------------------------------------------------------------------------------------#
# Sample plc client call for Modbus - based on
#   docker run -itd --rm -p 5020:5020 oitc/modbus-server:latest
#
# :URL:
#   https://hub.docker.com/r/oitc/modbus-server
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial/sample_modbus.al

policy_id = "mb10"
mapping_policy = blockchain get modbus where id = !policy_id
if not !mapping_policy then goto missing-mapping-policy

modbus_host      = from !mapping_policy bring [*][host]
modbus_port      = from !mapping_policy bring [*][port]
modbus_device_id = from !mapping_policy bring [*][device_id]
modbus_name      = from !mapping_policy bring [*][id]
mapping_logic    = from !mapping_policy bring [*][schema]

:msg-client:
on error goto msg-client-err
<run plc client where
    type = modbus and
    hostname = !modbus_host and
    port = !modbus_port and
    device_id = !modbus_device_id and
    frequency = 5 and
    name = !modbus_name and
    dbms = !default_dbms and
    map = !mapping_logic and
    dynamic=true and
    master_node=!ledger_conn>


:end-script:
end script

:terminate-scripts:
exit scripts

:missing-mapping-policy:
print "Mapping Policy not defined"
goto terminate-scripts

:msg-client-err:
print "Failed to define modbus PLC client"
goto terminate-scripts


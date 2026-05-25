#---------------------------------------------------------------------------------------------------------------------#
# Sample plc client call for Modbus - based on
#   docker run -itd --rm -p 5020:5020 oitc/modbus-server:latest
#
# :URL:
#   https://hub.docker.com/r/oitc/modbus-server
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial/sample_modbus.al

policy_id = "modbus-mapping"
mapping_policy = blockchain get modbus-mapping where id = !policy_id
if not !mapping_policy then goto missing-mapping-policy

table_name = from !mapping_policy bring [*][table]
mapping_logic = from !mapping_policy bring [*][schema]

:msg-client:
on error goto msg-client-err
<run plc client where
    type = modbus and
    hostname = 172.232.211.205 and
    port = 5020 and
    device_id = 1 and
    frequency = 5 and
    name = mb10 and
    dbms = !default_dbms and
    map = !mapping_logic and
    dynamic=true and master_node=!ledger_conn>


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


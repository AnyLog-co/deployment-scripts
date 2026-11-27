#----------------------------------------------------------------------------------------------------------------------#
# Sample deployment process for EtherIP
# https://github.com/AnyLog-co/documentation/blob/master/etherip.md
# :steps:
#   3. create EtherIP call
#   4. start EtherIP service
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/connectors/etherip_client.al

:check-vars:
on error ignore
if not !etherip_url then goto missing-etherip-url
if not !etherip_frequency then etherip_frequency = 1

:opcua-service:
on error goto etherip-service-error

<get etherip struct where
    url = !etherip_url and
    format = run_client and
    frequency = !etherip_frequency and
    name = etherip-client1 and
    dbms = !default_dbms and
    output = !tmp_dir/run_etherip_service.al>

on error ignore
process !tmp_dir/run_etherip_service.al

get plc client
:end-script:
end script

:missing-etherip-url:
print "Missing EtherIP URL cannot declare EtherIP connection"
goto end-script

:etherip-service-error:
print "Failed to start OPC-UA service"
goto end-script

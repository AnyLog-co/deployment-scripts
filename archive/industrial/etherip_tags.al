#----------------------------------------------------------------------------------------------------------------------#
# Sample deployment process for EtherIP
# https://github.com/AnyLog-co/documentation/blob/master/enthernetip.md
# :steps:
#   1. create EtherIP policies
#   2. declare policies
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/connectors/etherip_tags.al

:check-vars:
on error ignore
if not !etherip_url then goto missing-etherip-url
if not !etherip_frequency then etherip_frequency = 1

:create-policy:
on error goto create-policy-error

<get etherip struct where
    url = !etherip_url and
    format = policy  and
    schema = true and
    dbms = !default_dbms and
    target = "local = true and master = !ledger_conn" and
    output = !tmp_dir/etherip_policies.al>

on error ignore
process !tmp_dir/etherip_policies.al

:etherip-client:
on error ignore
process !local_scripts/connectors/etherip_client.al

:end-script:
end script

:missing-etherip-url:
print "Missing EtherIP URL cannot declare EtherIP connection"
goto end-script

:create-policy-error:
print "Failed to create OPC-UA policies"
goto end-script

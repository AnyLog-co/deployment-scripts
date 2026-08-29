#----------------------------------------------------------------------------------------------------------------------#
# Distributed Network Protocol 3 (DNP3) is a set of communications protocols used between components in process automation
# systems. Its main use is in utilities such as electric and water companies.
# The following provides a sample connect logic where the mapping resides a blockchain policy that can be reused with
# multiple DNP3 connections.
#
# Once a DNP3 southbound service is running, users cn view incoming insight via `get dnp3`
# <get dnp3 values where
#   hostname = 192.168.1.88 and
#   port = 20001 and
#   master_id = 1 and
#   outstation_id = 10 and
#   map = [
#      {"name":"analog_0","type":"Analog","index":0},
#      {"name":"binary_0","type":"Binary","index":0},
#      {"name":"analog_output_status_0","type":"AnalogOutputStatus","index":0},
#      {"name":"binary_output_status_0","type":"BinaryOutputStatus","index":0}
#   ]>

# <get dnp3 values where
#   hostname = 192.168.1.88 and
#   port = 20001 and
#   master_id = 1 and
#   outstation_id = 10 and
#   map = [
#      {"name":"analog_0","type":"Analog","index":0},
#      {"name":"binary_0","type":"Binary","index":0},
#      {"name":"analog_output_status_0","type":"AnalogOutputStatus","index":0},
#      {"name":"binary_output_status_0","type":"BinaryOutputStatus","index":0}
#   ] and
#   enable_tls = true and
#   tls_ca = !anylog_dir/dnp3_certs/factory_ca.cert and
#   tls_cert = !anylog_dir/dnp3_certs/master1.cert and
#   tls_key = !anylog_dir/dnp3_certs/master1.key
# >
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial/dnp3_connector.al

on error ignore
:set-params:
client_type=dnp3
dnp_ip = 192.168.1.88
dnp_port = 20001
dnp_master_id = 1
outstation_id  = 10
dnp_frequency = 20
dnp_name = plant1
base_namespace = "FACTORY4/DNP3/SUBSTATION"

# authentication configs
set enable_tls = false

# !anylog_dir is accessible as a volume and used to store certifications and access points.
# we can also store the public information on the blockchain sos there's no need for persistence of content
tls_ca = !anylog_dir/dnp3_certs/factory_ca.cert
tls_cert = !anylog_dir/dnp3_certs/master1.cert
tls_key = !anylog_dir/dnp3_certs/master1.key


:check-policy:
is_dnp3 = blockchain get dnp3 where namespace = !base_namespace and name=!dnp_name
if not !is_dnp3 then goto prep-policy

dnp_schema = from !is_dnp3 bring [*][schema]

goto declare-dnp3

:prep-policy:
<new_policy={
    "dnp3": {
        "namespace": !base_namespace,
        "name": !dnp_name,
        "schema": [
          {"name":"analog_0","type":"Analog","index":0},
          {"name":"binary_0","type":"Binary","index":0},
          {"name":"analog_output_status_0","type":"AnalogOutputStatus","index":0},
          {"name":"binary_output_status_0","type":"BinaryOutputStatus","index":0}
        ]
    }
}>

:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

:declare-dnp3:
on error goto declare-dnp3-err
if !enable_tls == true goto declare-dnp3-tls
<run plc client where type = dnp3 and
    hostname = !dnp_ip and
    port = !dnp_port and
    master_id = !dnp_master_id and
    outstation_id = !outstation_id and
    frequency = !dnp_frequency and
    name = !dnp_name and
    dbms = !default_dbms and
    dynamic = true and
    namespace = !base_namespace and
    master_node = !ledger_conn and
    map =  !dnp_schema
>
goto end-script

:declare-dnp3-tls:
<run plc client where type = dnp3 and
    hostname = !dnp_ip and
    port = !dnp_port and
    master_id = !dnp_master_id and
    outstation_id = !outstation_id and
    frequency = !dnp_frequency and
    name = !dnp_name and
    dbms = !default_dbms and
    dynamic = true and
    namespace = !base_namespace and
    master_node = !ledger_conn and
    map =  !dnp_schema and
    enable_tls = true and
    tls_ca = !tls_ca and
    tls_cert = !tls_cert and
    tls_key = !tls_key
>

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts

:declare-dnp3-err:
print "Failed to define connection to DNP3 against" + !dnp_ip + ":" + !dnp_port
goto terminate-scripts
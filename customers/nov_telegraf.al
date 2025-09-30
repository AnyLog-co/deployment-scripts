#----------------------------------------------------------------------------------------------------------------------#
# Mapping policy to accept data from Telegraf
# :sample-data:
# {"metrics":[
#  {
#    "fields":{"active":7080853504,"available":7166590976,"available_percent":41.715049743652344,"free":415137792,"inactive":6751453184,"total":17179869184,"used":10013278208,"used_percent":58.284950256347656,"wired":1292861440},#
#    "name":"mem", "tags":{"host":"Oris-Mac-mini.local"}, "timestamp":1715018940
#  },
#  {
#    "fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":89.91935483869311,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":2.7217741935480912,"usage_user":7.358870967749625},
#    "name":"cpu", "tags":{"cpu":"cpu0","host":"Oris-Mac-mini.local"}, "timestamp":1715018940
#  },
#  {
#    "fields":{"free":0,"total":0,"used":0,"used_percent":0},
#    "name":"swap","tags":{"host":"Oris-Mac-mini.local"},"timestamp":1715018940
#  },
#  {
#    "fields":{"bytes_recv":0,"bytes_sent":80,"drop_in":0,"drop_out":0,"err_in":0,"err_out":0,"packets_recv":0,"packets_sent":1,"speed":-1},
#    "name":"net", "tags":{"host":"Oris-Mac-mini.local","interface":"utun3"}, "timestamp":1715018940
#  }
# ]}
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/customers/nov_telegraf.al

on error ignore

:set-params:
policy_id = telegraf-mapping
topic_name=telegraf-data
set create_policy = false

:check-policy:
policy = blockchain get mapping where id = !policy_id
if !policy then goto msg-call
if !create_policy == true  and not !policy then goto declare-policy-error

:preparre-policy:
# for table name - the following includes both sensor and hostname; "bring [name] _ [tags][name]:[tags][host]",
#----
# "insert_id": {
#             "type": "string",
#            "default": "",
#            "bring": "[tags][insert_id]"
#        },

<new_policy = {"mapping": {
    "id" : !policy_id,
    "dbms" : !default_dbms,
    "table" : "bring [tags][table]",
    "schema" : {
        "timestamp" : {
            "type" : "timestamp",
            "default": "now()",
            "bring" : "[timestamp]"
        },
        "device_id": {
            "type": "string",
            "default": "",
            "bring": "[tags][device_id]"
        },
        "*" : {
            "type": "*",
            "bring": ["fields"]
        }
    }
}}>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

:msg-call:
on error goto msg-error
if !anylog_broker_port then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=!topic_name and
    policy=!policy_id
)>

if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and topic=(
    name=!topic_name and
    policy=!policy_id
)>

if not !anylog_broker_port and not !user_name and not !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=!topic_name and
    policy=!policy_id
)>

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign master policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member master policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare master policy on blockchain"
goto terminate-scripts

:msg-error:
echo "Failed to deploy MQTT process"
goto end-script


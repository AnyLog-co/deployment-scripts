#----------------------------------------------------------------------------------------------------------------------#
# Kafka client for winnio use case
# :step to update:
#   1. bring down network -- make down EDGELAKE_TYPE=[NODE_TYPE]
#   2. remove databases (including blockchain) -- for db in blockchain winnio_db almgm ; do psql -h 127.0.0.1 -p 5432 -U winnio -c "DROP DATABASE IF EXISTS ${db}" ; done
#   3. In operator nodes update local scripts to this
#   4. bring nodes up --  make up EDGELAKE_TYPE=[NODE_TYPE]
# :kafka-client:
# <run kafka consumer where
#    ip = "135.225.106.191"
#    and port = 9092
#    and reset = "earliest"
#    and topic = (
#        name = "pilback.data"
#        and dbms = "winniio_db"
#        and table = "pillback_sensors"
#        and column.timestamp = (type = "date" and value = "bring [timestamp]") X
#        and column.type = (type = "string" and value = "bring [type]") X
#        and column.system_id = (type = "string" and value = "bring [sensorId]")
#        and column.sequence_number = (type = "int" and value = "bring [sequenceNumber]")
#        and column.battery = (type = "float" and value = "bring [payload][battery]")
#        and column.event_count = (optional = true and type = "int" and value = "bring [payload][eventCount]")
#        and column.humidity = (optional = true and type = "float" and value = "bring [payload][humidity]")
#        and column.temperature = (optional = true and type = "float" and value = "bring [payload][temperature]")
#        and column.temperatureUnit = (optional = true and type = "string" and value = "bring [payload][temperatureUnit]")
#        and column.switch = (optional = true and type = "bool" and value = "bring [payload][switch]")
#        and column.adcIn = (optional = true and type = "string" and value = "bring [payload][adcIn]")
#        and column.adcMax  = (optional = true and type = "string" and value = "bring [payload][adcMax]")
#        and column.rs485 = (optional = true and type = "string" and value = "bring [payload][rs485]")
#        and column.co2value  = (optional = true and type = "float" and value = "bring [payload][co2Value]")
#        and column.trackingId = (optional = true and type = "int" and value = "bring [trackingId]")
#        and column.num_hops = (type = "int" and value = "bring [numHops]")
#        and column.max_hops = (type = "int" and value = "bring [maxHops]")
#        and column.id = (type = "int" and value = "bring [id]")
# )>
#----------------------------------------------------------------------------------------------------------------------#
# process deployment-scripts/customers/winnio_kafka.al

on error ignore
set create_policy = true

:set-params
policy_id = winnio_kafka_policy
kafka_ip = 135.225.106.191
kafka_port = 9092
kafka_reset = earliest
topic = pilback.data
db_name = winniio_db
table_name =  pillback_sensors

:check-policy:
is_policy = blockchain get mapping where id = !policy_id
if !is_policy then goto run-policy
else if not !is_policy and !create_policy == false then goto policy-error

:declare-policy:
<new_policy = {
    "mapping": {
        "id": !policy_id,
        "dbms": !db_name,
        "table": !table_name,
        "readings": "payload",
        "schema": {
            "timestamp": {
                "bring": "[timestamp]",
                "default": "now()",
                "type": "timestamp",
                "apply": "epoch_to_datetime",
                "root": true
            },
            "sensor_id": {
                "bring": "[sensorId]",
                "type": "int",
                "root": true
            },
            "type": {
                "bring": "[type]",
                "type": "string",
                "root": true
            },
            "id": {
                "bring": "[id]",
                "type": "int",
                "root": true
            },
            "sequence_number": {
                "bring": "[sequenceNumber]",
                "type": "int",
                "root": true
            },
            "battery": {
                "bring": "[battery]",
                "type": "float",
                "default": ""
            },
            "event_count": {
                "bring": "[eventCount]",
                "type": "int",
                "optional": true,
                "default": 0
            },
            "humidity": {
                "bring": "[humidity]",
                "type": "float",
                "optional": true,
                "default": ""
            },
            "temperature": {
                "bring": "[temperature]",
                "type": "float",
                "optional": true,
                "default": ""
            },
            "temperatureUnit": {
                "bring": "[temperatureUnit]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "switch": {
                "bring": "[switch]",
                "type": "bool",
                "optional": true,
                "default": false
            },
            "adcIn": {
                "bring": "[adcIn]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "adcMax": {
                "bring": "[adcMax]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "rs485": {
                "bring": "[rs485]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "co2value": {
                "bring": "[co2Value]",
                "type": "float",
                "optional": true,
                "default": ""
            },
            "trackingId": {
                "bring": "[trackingId]",
                "type": "int",
                "optional": true,
                "root": true,
                "default": 0
            },
            "num_hops": {
                "bring": "[numHops]",
                "type": "int",
                "root": true
            },
            "max_hops": {
                "bring": "[maxHops]",
                "type": "int",
                "root": true
            }
        }
    }
}>

:publish-policy:

process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = false
goto check-policy


:run-policy:
on error cal kafka-error
<run kafka consumer where
    ip = !kafka_ip and
    port = !kafka_port and
    reset = !kafka_reset and
    topic = (name=!topic and policy=!policy_id)
>

 :end-script:
 end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts

:kafka-error:
print "Failed to execute Kafka consumer service"
goto terminate-scripts
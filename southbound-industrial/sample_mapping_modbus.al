#---------------------------------------------------------------------------------------------------------------------#
# Sample mapping policy for Modbus - based on
#   docker run -itd --rm -p 5020:5020 oitc/modbus-server:latest
#
# :URL:
#   https://hub.docker.com/r/oitc/modbus-server
#            {"name": "door_sensor", "discreteInput": 0},
#            {"name": "motion_detected", "discreteInput": 1},
#            {"name": "water_leak", "discreteInput": 2},
#            {"name": "emergency_stop", "discreteInput": 3},
#            {"name": "maintenance_mode", "discreteInput": 4}
#
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial/sample_mapping_modbus.al

on error ignore

policy_id = "modbus-mapping"
set create_policy = false

:check-policy:
is_policy = blockchain get modbus where id = !policy_id
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto end-script
else if not !is_policy and !create_policy == true then goto declare-policy-error

:declare-policy:
set new_policy = ""
<new_policy = {
    "modbus": {
        "id": "mb10",
        "host": "172.232.211.205",
        "port": 5020,

        "device_id": 1,

        "schema": [
            {"name": "kitchen_temperature", "register": 0},
            {"name": "kitchen_humidity", "register": 1},
            {"name": "pressure", "register": 2},
            {"name": "status_code", "register": 3},
            {"name": "energy_total", "register": 5},

            {"name": "analog_sensor_0", "inputRegister": 0},
            {"name": "analog_sensor_1", "inputRegister": 1},
            {"name": "adc_raw", "inputRegister": 2},
            {"name": "voltage", "inputRegister": 3},
            {"name": "runtime_seconds", "inputRegister": 4},

            {"name": "pump_running", "coil": 0},
            {"name": "motor_enabled", "coil": 1},
            {"name": "valve_open", "coil": 2},
            {"name": "alarm_active", "coil": 3},
            {"name": "system_ready", "coil": 4}

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



#----------------------------------------------------------------------------------------------------------------------#
# Schedule policy to get insight about water and waste water - to be run from query node
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/smart_city_notification.al



on error ignore

:set-params:
schedule_id = smart-city-notification
set create_policy = false


:check-policy:
is_policy = blockchain get schedule where id=!schedule_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:create-policy
<new_policy = {"schedule": {
    "id": !schedule_id,
    "script": [
        "schedule name=waste-water and time="15 minutes" task thread !local_scripts/sample-scripts/smart_city_waste_water_notification.al",
        "schedule name=waste-water-analog and time="5 minutes" task thread !local_scripts/sample-scripts/smart_city_waste_water_analog_notification.al",
        "schedule name=water-digital and time="5 minutes" task thread !local_scripts/sample-scripts/smart_city_water_notification.al",
        "schedule name=water-analog and time="5 minutes" task thread !local_scripts/sample-scripts/smart_city_water_analog_notification.al"
    ]
}>


:publish-policy:
on error ignore
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error

:config-policy:
on error goto config-policy-error
config from policy where id=!schedule_id

:end-script:
end script

:terminate-scripts:
exit scripts

:missing-socket-error:
echo "Missing docker.socket cannot configure docker monitoring"
do goto end-script

:store-monitoring-error:
print "Failed to store "
:config-policy-error:
print "Failed to configure node based on Schedule ID"
goto terminate-scripts

:sign-policy-error:
print "Failed to sign schedule policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member schedule policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare schedule policy on blockchain"
goto terminate-scripts





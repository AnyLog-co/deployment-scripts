#----------------------------------------------------------------------------------------------------------------------#
# Configure docker monitoring
# NOTE: not supported for non-operator nodes - can work with publisher if user defines distribution
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/southbound-monitoring/policy_docker_monitoring.al

on error ignore

:set-params:
schedule_id = docker-monitoring
set create_policy = false


:check-policy:
is_policy = blockchain get schedule where id=!schedule_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:create-policy
<new_policy = {
    "schedule": {
        "id": !schedule_id,
        "name": "Docker Monitoring Schedule",
        "script": [
            "run scheduled pull where name = docker_insights and type = docker and frequency = 30 and continuous = true and dbms = monitoring and table = docker_insight"
        ]
    }
}>


:publish-policy:
on error ignore
process !local_scripts/policies/publish_policy.al
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


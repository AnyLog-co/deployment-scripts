#----------------------------------------------------------------------------------------------------------------------#
# Declare cluster and operator policies on the blockchain
#   --> declare `operator_conn` used as host value for cluster
#   --> check cluster ID
#   --> if cluster ID DNE, create cluster policy and recheck for ID
#   --> check operator ID
#   --> if operator ID DNE, create operator policy and recheck for ID
#
# :sample-policies:
#   {'cluster' : {'company' : 'New Company',
#               'host' : '178.79.143.174:32248',
#               'name' : 'AnyLog-cluster-2',
#               'status' : 'active',
#               'id' : '1ccd858777bcc2d748c7672e848d6338',
#               'date' : '2023-09-12T22:40:39.396249Z',
#               'ledger' : 'global'
#   }},
#   {'operator' : {'company' : 'New Company',
#                'cluster' : '1ccd858777bcc2d748c7672e848d6338',
#                'name' : 'AnyLog-operator-1',
#                'ip' : '178.79.143.174',
#                'internal_ip' : '178.79.143.174',
#                'port' : 32148,
#                'rest_port' : 32149,
#                'member' : 101,
#                'id' : '9e7eaa4e0d5af9bb25dc12855d04c782',
#                'date' : '2023-09-12T22:43:23.627572Z',
#                'ledger' : 'global'
#   }}
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/training/generic_policies/declare_operator_policy.al
on error ignore
operator_conn = !ip + : + !anylog_server_port

i = 0
:cluster-id:
cluster_id = blockchain get cluster where host=!operator_conn and company=!company_name bring [*][id]
if !cluster_id then goto operator-id
if !i == 1 then goto cluster-id-error

new_policy = create policy cluster with defaults where company=!company_name and host=!operator_conn
goto declare-policy

:operator-id:
on error ignore
if not !j then j = 0
operator_id = blockchain get operator where company=!company_name and cluster=!cluster_id bring [*][id]
if !operator_id then goto end-script
if !j == 1 then goto operator-id-error

new_policy = create policy operator with defaults where company=!company_name and cluster=!cluster_id and port=!anylog_server_port and rest=!anylog_rest_port and broker=!anylog_broker_port
goto declare-policy


:declare-policy:
process !local_scripts/training/publish_policy.al
if error_code == 1 then goto sign-policy-error
if error_code == 2 then goto prepare-policy-error
if error_code == 3 then declare-policy-error

if !j == 0 then
do j = 1
do goto operator-id
goto cluster-id


:end-script:
end script

:terminate-scripts:
exit scripts

:cluster-id-error:
echo "Failed to declare cluster policy, cannot continue..."
goto terminate-scripts

:operator-id-error:
echo "Failed to declare operator policy, cannot continue..."
goto terminate-scripts

:sign-policy-error:
if !j then echo "Failed to sign operator policy"
else echo "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
if !j then echo "Failed to prepare operator policy for publishing on blockchain"
else echo "Failed to prepare cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
if !j then echo "Failed to declare operator policy on blockchain"
else echo "Failed to declare cluster policy on blockchain"
goto terminate-scripts
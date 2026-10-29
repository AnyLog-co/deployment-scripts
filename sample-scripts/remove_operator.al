#----------------------------------------------------------------------------------------------------------------------#
# Remove an operator from the network, as if it had never been registered.
#   Run on the MASTER node (the node holding the ledger), not on the operator being removed.
#   Every operator policy matching operator_name and operator_ip is removed from:
#       1. the local blockchain file    - blockchain delete policy where id = ... and local = true
#       2. the master ledger            - blockchain drop policy where id = ...
#   Cluster child policies (parent = cluster id) published from the operator's IP are removed too. Children published
#   by other nodes stay, so the cluster policy stays while any other child references it.
#   The config, orchestrator and cluster policies referenced by the operator policy are removed only when
#   no other policy in the ledger still references them (they can be shared with other nodes).
#   Other policies issued from the operator's IP are listed in the dry run for manual review, not removed.
#   Other nodes drop the policies on their next blockchain sync (BLOCKCHAIN_SYNC).
#   The script refuses to remove the node it is running on (node_name), including a standalone operator.
#
# Usage - pass the parameters on the process command, in this order (all three are required):
#   process !local_scripts/sample-scripts/remove_operator.al <operator_name> <operator_ip> <confirm>
#   Dry run (lists the matching policies, no changes):
#     process !local_scripts/sample-scripts/remove_operator.al anylog-standalone-operator 136.23.47.189 false
#   Apply the removal:
#     process !local_scripts/sample-scripts/remove_operator.al anylog-standalone-operator 136.23.47.189 true
#----------------------------------------------------------------------------------------------------------------------#
variables(operator_name, operator_ip, confirm)
on error ignore

set last_policy_id = none
set last_child_id = none

if not !operator_name then goto missing-params
if not !operator_ip then goto missing-params
if !operator_name == !node_name then goto self-removal-error

:find-policies:
policy_count = blockchain get operator where name = !operator_name and ip = !operator_ip bring.count
if not !policy_count then goto no-policies
print "Found " !policy_count " operator policy(ies) for name=" !operator_name " ip=" !operator_ip
if !confirm != true then goto dry-run

:remove-next:
policy_id = blockchain get operator where name = !operator_name and ip = !operator_ip bring.first [*][id]
if not !policy_id then goto removal-done
# The same ID found twice means the previous removal did not take effect
if !policy_id == !last_policy_id then goto removal-stuck
set last_policy_id = !policy_id
set config_id = ""
set orchestrator_id = ""
set cluster_id = ""
config_id = blockchain get operator where id = !policy_id bring.first [*][config]
orchestrator_id = blockchain get operator where id = !policy_id bring.first [*][orchestrator]
cluster_id = blockchain get operator where id = !policy_id bring.first [*][cluster]

blockchain delete policy where id = !policy_id and local = true
blockchain drop policy where id = !policy_id
blockchain reload metadata
print "Removed operator policy id: " !policy_id
goto remove-children

:removal-done:
policy_count = blockchain get operator where name = !operator_name and ip = !operator_ip bring.count
if !policy_count then goto removal-stuck
print "Operator removed from the network: name=" !operator_name " ip=" !operator_ip
goto end-script

:removal-stuck:
print "Could not remove all operator policies for name=" !operator_name " ip=" !operator_ip " - check the ledger and local blockchain file"
goto end-script

:dry-run:
print "Dry run - no changes made. Re-run with confirm = true as the last parameter to apply the removals listed below."
policy_id = blockchain get operator where name = !operator_name and ip = !operator_ip bring.first [*][id]
config_id = blockchain get operator where id = !policy_id bring.first [*][config]
orchestrator_id = blockchain get operator where id = !policy_id bring.first [*][orchestrator]
cluster_id = blockchain get operator where id = !policy_id bring.first [*][cluster]
print "Other ledger entries issued from ip " !operator_ip " (not removed by this script - review manually):"
sql blockchain format=table and stat=false select policy_type, policy_id, company_name from ledger where host = '!operator_ip' and policy_id != '!policy_id'
goto list-children

# An empty count is treated as still referenced (ref_count != 0), so nothing is dropped on a failed query
:list-children:
if not !cluster_id then goto check-config
print "Cluster child policies published from ip " !operator_ip " (removed when confirm = true):"
sql blockchain format=table and stat=false select policy_id, company_name from ledger where policy_type = 'cluster' and policy like '%!cluster_id%' and policy_id != '!cluster_id' and policy like '%Node at !operator_ip:%'
goto check-config

# Child cluster policies are removed one at a time, then the loop re-counts until none are left
:remove-children:
if not !cluster_id then goto check-config
sql_count = sql blockchain format=json:list and stat=false select count(*) as count from ledger where policy_type = 'cluster' and policy like '%!cluster_id%' and policy_id != '!cluster_id' and policy like '%Node at !operator_ip:%'
serialized_count = python !sql_count.replace('[', '').replace(']', '')
child_count = from !serialized_count bring [count]
if not !child_count then goto check-config
if !child_count == 0 then goto check-config
child_id_list = sql blockchain format=json:list and stat=false select policy_id from ledger where policy_type = 'cluster' and policy like '%!cluster_id%' and policy_id != '!cluster_id' and policy like '%Node at !operator_ip:%' limit 1
serialized_id = python !child_id_list.replace('[', '').replace(']', '')
child_policy_id = from !serialized_id bring [policy_id]
if not !child_policy_id then goto check-config
if !child_policy_id == !last_child_id then print "Could not remove cluster child policy id: " !child_policy_id " - check the ledger and local blockchain file"
if !child_policy_id == !last_child_id then goto check-config
set last_child_id = !child_policy_id
blockchain delete policy where id = !child_policy_id and local = true
blockchain drop policy where id = !child_policy_id
blockchain reload metadata
print "Removed cluster child policy id: " !child_policy_id " (published from ip " !operator_ip ")"
goto remove-children

:check-config:
if not !config_id then goto check-orchestrator
sql_count = sql blockchain format=json:list and stat=false select count(*) as count from ledger where policy like '%!config_id%' and policy_id != '!config_id' and policy_id != '!policy_id'
serialized_count = python !sql_count.replace('[', '').replace(']', '')
ref_count = from !serialized_count bring [count]
if !ref_count != 0 then print "Keep config policy - still used by other policies: " !config_id
if !ref_count == 0 then print "Config policy not used by other policies: " !config_id
if !ref_count == 0 and !confirm == true then blockchain drop policy where id = !config_id

:check-orchestrator:
if not !orchestrator_id then goto check-cluster
sql_count = sql blockchain format=json:list and stat=false select count(*) as count from ledger where policy like '%!orchestrator_id%' and policy_id != '!orchestrator_id' and policy_id != '!policy_id'
serialized_count = python !sql_count.replace('[', '').replace(']', '')
ref_count = from !serialized_count bring [count]
if !ref_count != 0 then print "Keep orchestrator policy - still used by other policies: " !orchestrator_id
if !ref_count == 0 then print "Orchestrator policy not used by other policies: " !orchestrator_id
if !ref_count == 0 and !confirm == true then blockchain drop policy where id = !orchestrator_id

:check-cluster:
if not !cluster_id then goto after-checks
sql_count = sql blockchain format=json:list and stat=false select count(*) as count from ledger where policy like '%!cluster_id%' and policy_id != '!cluster_id' and policy_id != '!policy_id' and not (policy_type = 'cluster' and policy like '%Node at !operator_ip:%')
serialized_count = python !sql_count.replace('[', '').replace(']', '')
ref_count = from !serialized_count bring [count]
if !ref_count != 0 then print "Keep cluster policy - still used by other policies: " !cluster_id
if !ref_count == 0 then print "Cluster policy not used by other policies: " !cluster_id
if !ref_count == 0 and !confirm == true then blockchain drop policy where id = !cluster_id

:after-checks:
if !confirm == true then goto remove-next
goto end-script

:no-policies:
print "No operator policy found for name=" !operator_name " ip=" !operator_ip " - nothing to remove"
goto end-script

:self-removal-error:
print "Refusing to remove operator " !operator_name " - it is the node this script is running on"
goto end-script

:missing-params:
print "Usage: process !local_scripts/sample-scripts/remove_operator.al <operator_name> <operator_ip> <confirm>"

:end-script:
end script

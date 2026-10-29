#----------------------------------------------------------------------------------------------------------------------#
# Remove a node of any type (master, operator, publisher, query, generic, relay) from the network, as if it had never
# been registered.
#   Run on the MASTER node (the node holding the ledger), not on the node being removed.
#   Every node policy matching target_name and target_ip is removed from:
#       1. the local blockchain file    - blockchain delete policy where id = ... and local = true
#       2. the master ledger            - blockchain drop policy where id = ...
#   The config, orchestrator and cluster policies referenced by the node policy are removed only when
#   no other policy in the ledger still references them (they can be shared with other nodes).
#   Other policies issued from the node's IP are listed in the dry run for manual review, not removed.
#   Other nodes drop the policies on their next blockchain sync (BLOCKCHAIN_SYNC).
#   The script refuses to remove the node it is running on (node_name).
#   A master node can only be removed from a master node (NODE_TYPE master, master-operator or master-publisher).
#
# Parameters - set them before processing this script:
#   set target_name = anylog-standalone-operator
#   set target_ip = 136.23.47.189
#   set confirm = true          (omit, or set to false, for a dry run that only lists the matching policies)
#
# Usage:
#   process !local_scripts/sample-scripts/remove_node.al
#----------------------------------------------------------------------------------------------------------------------#
on error ignore

set last_policy_id = none

if not !target_name then goto missing-params
if not !target_ip then goto missing-params
if !target_name == !node_name then goto self-removal-error
if not !confirm then set confirm = false

set local_is_master = false
if $NODE_TYPE == master or $NODE_TYPE == master-operator or $NODE_TYPE == master-publisher then set local_is_master = true
master_count = blockchain get master where name = !target_name and ip = !target_ip bring.count
if !master_count and !local_is_master != true then goto master-target-error

:find-nodes:
node_count = blockchain get (master,operator,publisher,query,generic,relay) where name = !target_name and ip = !target_ip bring.count
if not !node_count then goto no-nodes
print "Found " !node_count " node policy(ies) for name=" !target_name " ip=" !target_ip
if !confirm != true then goto dry-run

:remove-next:
policy_id = blockchain get (master,operator,publisher,query,generic,relay) where name = !target_name and ip = !target_ip bring.first [*][id]
if not !policy_id then goto removal-done
# The same ID found twice means the previous removal did not take effect
if !policy_id == !last_policy_id then goto removal-stuck
set last_policy_id = !policy_id
set config_id = ""
set orchestrator_id = ""
set cluster_id = ""
config_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][config]
orchestrator_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][orchestrator]
cluster_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][cluster]

blockchain delete policy where id = !policy_id and local = true
blockchain drop policy where id = !policy_id
blockchain reload metadata
print "Removed node policy id: " !policy_id
goto check-config

:removal-done:
node_count = blockchain get (master,operator,publisher,query,generic,relay) where name = !target_name and ip = !target_ip bring.count
if !node_count then goto removal-stuck
print "Node removed from the network: name=" !target_name " ip=" !target_ip
goto end-script

:removal-stuck:
print "Could not remove all node policies for name=" !target_name " ip=" !target_ip " - check the ledger and local blockchain file"
goto end-script

:dry-run:
print "Dry run - no changes made. Set confirm = true to apply the removals listed below."
policy_id = blockchain get (master,operator,publisher,query,generic,relay) where name = !target_name and ip = !target_ip bring.first [*][id]
config_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][config]
orchestrator_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][orchestrator]
cluster_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][cluster]
print "Other ledger entries issued from ip " !target_ip " (not removed by this script - review manually):"
sql blockchain format=table and stat=false select policy_type, policy_id, company_name from ledger where host = '!target_ip' and policy_id != '!policy_id'
goto check-config

# An empty count is treated as still referenced (ref_count != 0), so nothing is dropped on a failed query
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
sql_count = sql blockchain format=json:list and stat=false select count(*) as count from ledger where policy like '%!cluster_id%' and policy_id != '!cluster_id' and policy_id != '!policy_id'
serialized_count = python !sql_count.replace('[', '').replace(']', '')
ref_count = from !serialized_count bring [count]
if !ref_count != 0 then print "Keep cluster policy - still used by other policies: " !cluster_id
if !ref_count == 0 then print "Cluster policy not used by other policies: " !cluster_id
if !ref_count == 0 and !confirm == true then blockchain drop policy where id = !cluster_id

:after-checks:
if !confirm == true then goto remove-next
goto end-script

:master-target-error:
print "Refusing to remove master node " !target_name " from a non-master node - run this script on a master node"
goto end-script

:no-nodes:
print "No node policy found for name=" !target_name " ip=" !target_ip " - nothing to remove"
goto end-script

:self-removal-error:
print "Refusing to remove node " !target_name " - it is the node this script is running on"
goto end-script

:missing-params:
print "Set target_name and target_ip before processing this script"

:end-script:
end script

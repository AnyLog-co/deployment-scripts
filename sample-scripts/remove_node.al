# Remove node policies and their unused dependencies from a master's local ledger.
#
# Before running:
#   Stop the target node so it cannot re-register or publish more policies. Quiesce
#   other policy writers and make sure the master's local blockchain is synchronized
#   with its ledger and its synchronizer is running. Back up both before applying.
#   Apply refuses to run if either copy has policy IDs missing from the other:
#   some master synchronizers replace the file without preserving local-only policies.
#   Child ownership is inferred from current node-policy IP and port values.
#   The script refuses to apply if the name identifies different endpoints or
#   companies, or if any cluster child's source cannot be attributed uniquely.
#   An external or historical endpoint may not appear in a node policy. Review
#   such children manually; do not assume the script can identify their owner.
#
# Usage (both arguments are required):
#   process !local_scripts/sample-scripts/remove_node.al <node_name> <confirm>
#   process !local_scripts/sample-scripts/remove_node.al anylog-operator false
#   process !local_scripts/sample-scripts/remove_node.al anylog-operator true
#
# A dry run lists matching nodes and their cluster children, with inferred owners.
# Attribution uses advertised IP and port and assumes endpoints have not been
# reused by another node. Review the dry run before applying.
# Config, orchestrator and cluster policies are removed only if no other policy
# references them through config, orchestrator, cluster or parent. Other policies
# and target data are not removed.
# Other nodes learn about ledger changes on their next blockchain sync.

variables(rmn_target_name, rmn_confirm)
on error end script

if not !rmn_target_name then goto missing-params
if !rmn_confirm != true and !rmn_confirm != false then goto missing-params
if not !node_name then goto local-name-error
if !rmn_target_name == !node_name then goto self-removal-error

if $NODE_TYPE != master and $NODE_TYPE != master-operator and $NODE_TYPE != master-publisher then goto master-error

blockchain reload metadata
rmn_nodes = blockchain get (master,operator,publisher,query,generic,relay) where name = !rmn_target_name
if not !rmn_nodes then goto no-nodes
if !rmn_confirm == false then print "Dry run; no policies removed. Matching node policies:"
if !rmn_confirm == false then print !rmn_nodes

# Validate all matches and child ownership before making any changes.
rmn_node_count = from !rmn_nodes bring.count
rmn_all_nodes = blockchain get (master,operator,publisher,query,generic,relay)
rmn_all_count = from !rmn_all_nodes bring.count
set rmn_node_index = 0

:identify-node:
if !rmn_node_index.int >= !rmn_node_count.int then goto identification-complete
rmn_current_ip = from !rmn_nodes(!rmn_node_index) bring [*][ip]
rmn_current_port = from !rmn_nodes(!rmn_node_index) bring [*][port]
rmn_current_company = from !rmn_nodes(!rmn_node_index) bring [*][company]
if !rmn_node_count.int == 1 then goto identify-children
if not !rmn_current_ip or not !rmn_current_port or not !rmn_current_company then goto ambiguous-name
if !rmn_node_index.int == 0 then goto record-identity
if !rmn_current_ip != !rmn_identity_ip or !rmn_current_port != !rmn_identity_port or !rmn_current_company != !rmn_identity_company then goto ambiguous-name
goto identify-children

:record-identity:
set rmn_identity_ip = !rmn_current_ip
set rmn_identity_port = !rmn_current_port
set rmn_identity_company = !rmn_current_company

:identify-children:
rmn_current_cluster = from !rmn_nodes(!rmn_node_index) bring [*][cluster]
if not !rmn_current_cluster then goto next-node
rmn_children = blockchain get cluster where parent = !rmn_current_cluster
if not !rmn_children then goto next-node
print "Cluster children under " !rmn_current_cluster ":"
print !rmn_children
if not !rmn_current_ip or not !rmn_current_port then goto ambiguous-child
rmn_child_count = from !rmn_children bring.count
set rmn_child_index = 0

:identify-child:
if !rmn_child_index.int >= !rmn_child_count.int then goto next-node
rmn_child_id = from !rmn_children(!rmn_child_index) bring [*][id]
rmn_child_source = from !rmn_children(!rmn_child_index) bring [*][source]
if not !rmn_child_id or not !rmn_child_source then goto ambiguous-child
set rmn_target_owner = false
set rmn_other_owner = false
set rmn_owner_index = 0

:identify-owner:
if !rmn_owner_index.int >= !rmn_all_count.int then goto check-child-owner
rmn_owner_type = from !rmn_all_nodes(!rmn_owner_index) bring [*]
rmn_owner_cluster = from !rmn_all_nodes(!rmn_owner_index) bring [*][cluster]
rmn_owner_ip = from !rmn_all_nodes(!rmn_owner_index) bring [*][ip]
rmn_owner_port = from !rmn_all_nodes(!rmn_owner_index) bring [*][port]
if !rmn_owner_type == operator and !rmn_owner_cluster == !rmn_current_cluster and (not !rmn_owner_ip or not !rmn_owner_port) then goto ambiguous-child
if not !rmn_owner_ip or not !rmn_owner_port then goto next-owner
rmn_owner_source = "Node at " + !rmn_owner_ip + ":" + !rmn_owner_port
if !rmn_owner_source != !rmn_child_source then goto next-owner
rmn_owner_name = from !rmn_all_nodes(!rmn_owner_index) bring [*][name]
if !rmn_owner_name == !rmn_target_name then set rmn_target_owner = true
else set rmn_other_owner = true

:next-owner:
rmn_owner_index = incr !rmn_owner_index 1
goto identify-owner

:check-child-owner:
if !rmn_target_owner == true and !rmn_other_owner == true then goto ambiguous-child
if !rmn_target_owner != true and !rmn_other_owner != true then goto ambiguous-child
if !rmn_target_owner == true then print "Target child: " !rmn_child_id " source: " !rmn_child_source
else print "Keep child of another node: " !rmn_child_id " source: " !rmn_child_source
rmn_child_index = incr !rmn_child_index 1
goto identify-child

:next-node:
rmn_node_index = incr !rmn_node_index 1
goto identify-node

:identification-complete:
if !rmn_confirm == false then goto dry-run

# A stale or local-only policy can be lost when a master synchronizer refreshes
# from its database. Check both ID sets before the first destructive command.
rmn_ledger_count_row = sql blockchain format=json:list and stat=false select count(*) as count from ledger
rmn_ledger_count = from !rmn_ledger_count_row(0) bring [count]
rmn_local_count = blockchain get * bring.count
if !rmn_local_count != !rmn_ledger_count then goto unsynchronized-error
if !rmn_ledger_count == 0 then goto unsynchronized-error
rmn_ledger_rows = sql blockchain format=json:list and stat=false select policy_id from ledger
rmn_ledger_count = from !rmn_ledger_rows bring.count
set rmn_ledger_index = 0

:verify-ledger-row:
if !rmn_ledger_index.int >= !rmn_ledger_count.int then goto preflight-complete
rmn_ledger_id = from !rmn_ledger_rows(!rmn_ledger_index) bring [policy_id]
rmn_exists = blockchain get * where id = !rmn_ledger_id
if not !rmn_exists then goto unsynchronized-error
rmn_ledger_index = incr !rmn_ledger_index 1
goto verify-ledger-row

:preflight-complete:
run blockchain sync

:remove-next:
rmn_policy_id = blockchain get (master,operator,publisher,query,generic,relay) where name = !rmn_target_name bring.first [*][id]
if not !rmn_policy_id then goto removal-done
rmn_config_id = blockchain get * where id = !rmn_policy_id bring.first [*][config]
rmn_orchestrator_id = blockchain get * where id = !rmn_policy_id bring.first [*][orchestrator]
rmn_cluster_id = blockchain get * where id = !rmn_policy_id bring.first [*][cluster]
rmn_current_ip = blockchain get * where id = !rmn_policy_id bring.first [*][ip]
rmn_current_port = blockchain get * where id = !rmn_policy_id bring.first [*][port]

:remove-children:
if not !rmn_cluster_id then goto check-config
if not !rmn_current_ip or not !rmn_current_port then goto check-config
rmn_child_source = "Node at " + !rmn_current_ip + ":" + !rmn_current_port
rmn_children = blockchain get cluster where parent = !rmn_cluster_id and source = !rmn_child_source
if not !rmn_children then goto check-config
rmn_child_id = blockchain get cluster where parent = !rmn_cluster_id and source = !rmn_child_source bring.first [*][id]
if not !rmn_child_id then goto child-id-error
set rmn_delete_id = !rmn_child_id
call remove-policy
goto remove-children

:check-config:
if not !rmn_config_id then goto check-orchestrator
rmn_ref_count = blockchain get * where config = !rmn_config_id bring.count
rmn_other_config_refs = blockchain get * where orchestrator = !rmn_config_id bring.count
rmn_other_cluster_refs = blockchain get * where cluster = !rmn_config_id bring.count
rmn_parent_count = blockchain get * where parent = !rmn_config_id bring.count
if !rmn_ref_count != 1 or !rmn_parent_count or !rmn_other_config_refs or !rmn_other_cluster_refs then goto keep-config
rmn_exists = blockchain get config where id = !rmn_config_id
if not !rmn_exists then goto check-orchestrator
set rmn_delete_id = !rmn_config_id
call remove-policy
goto check-orchestrator

:keep-config:
print "Keeping config policy with other or unverified references: " !rmn_config_id

:check-orchestrator:
if not !rmn_orchestrator_id then goto check-cluster
rmn_ref_count = blockchain get * where orchestrator = !rmn_orchestrator_id bring.count
rmn_other_config_refs = blockchain get * where config = !rmn_orchestrator_id bring.count
rmn_other_cluster_refs = blockchain get * where cluster = !rmn_orchestrator_id bring.count
rmn_parent_count = blockchain get * where parent = !rmn_orchestrator_id bring.count
if !rmn_ref_count != 1 or !rmn_parent_count or !rmn_other_config_refs or !rmn_other_cluster_refs then goto keep-orchestrator
rmn_exists = blockchain get orchestrator where id = !rmn_orchestrator_id
if not !rmn_exists then goto check-cluster
set rmn_delete_id = !rmn_orchestrator_id
call remove-policy
goto check-cluster

:keep-orchestrator:
print "Keeping orchestrator policy with other or unverified references: " !rmn_orchestrator_id

:check-cluster:
if not !rmn_cluster_id then goto remove-node
rmn_ref_count = blockchain get * where cluster = !rmn_cluster_id bring.count
rmn_other_config_refs = blockchain get * where config = !rmn_cluster_id bring.count
rmn_other_orchestrator_refs = blockchain get * where orchestrator = !rmn_cluster_id bring.count
rmn_parent_count = blockchain get * where parent = !rmn_cluster_id bring.count
if !rmn_ref_count != 1 or !rmn_parent_count or !rmn_other_config_refs or !rmn_other_orchestrator_refs then goto keep-cluster
rmn_exists = blockchain get cluster where id = !rmn_cluster_id
if not !rmn_exists then goto remove-node
set rmn_delete_id = !rmn_cluster_id
call remove-policy
goto remove-node

:keep-cluster:
print "Keeping cluster policy with other or unverified references: " !rmn_cluster_id

:remove-node:
set rmn_delete_id = !rmn_policy_id
call remove-policy
goto remove-next

# The ledger may not contain a locally declared policy. Check exact IDs before
# dropping it; a missing ledger row is also possible after an interrupted run.
:remove-policy:
rmn_ledger_count_row = sql blockchain format=json:list and stat=false select count(*) as count from ledger
rmn_ledger_count = from !rmn_ledger_count_row(0) bring [count]
if !rmn_ledger_count == 0 then goto drop-local
rmn_ledger_rows = sql blockchain format=json:list and stat=false select policy_id from ledger
rmn_ledger_count = from !rmn_ledger_rows bring.count
set rmn_ledger_index = 0

:check-ledger-row:
if !rmn_ledger_index.int >= !rmn_ledger_count.int then goto drop-local
rmn_ledger_id = from !rmn_ledger_rows(!rmn_ledger_index) bring [policy_id]
if !rmn_ledger_id == !rmn_delete_id then goto drop-ledger
rmn_ledger_index = incr !rmn_ledger_index 1
goto check-ledger-row

:drop-ledger:
blockchain drop policy where id = !rmn_delete_id

:drop-local:
blockchain delete policy where id = !rmn_delete_id and local = true
set rmn_sync_wait = 0

:wait-for-sync:
rmn_exists = blockchain read (master,operator,publisher,query,generic,relay,config,orchestrator,cluster) where id = !rmn_delete_id
if not !rmn_exists then goto verify-removal
if !rmn_sync_wait.int >= 30 then goto sync-error
wait 1
rmn_sync_wait = incr !rmn_sync_wait 1
goto wait-for-sync

:verify-removal:
blockchain reload metadata
rmn_exists = blockchain get (master,operator,publisher,query,generic,relay,config,orchestrator,cluster) where id = !rmn_delete_id
if !rmn_exists then goto removal-stuck
print "Removed policy: " !rmn_delete_id
return

:dry-run:
print "Review the nodes' config, orchestrator and cluster IDs and their other references before applying."
goto end-script

:removal-done:
rmn_nodes = blockchain get (master,operator,publisher,query,generic,relay) where name = !rmn_target_name
if !rmn_nodes then goto node-id-error
print "Matching node policies removed: name=" !rmn_target_name
goto end-script

:removal-stuck:
print "Removal failed: policy remains in the local blockchain: " !rmn_delete_id
goto end-script

:sync-error:
print "Removal stopped: local blockchain did not sync within 30 seconds for policy " !rmn_delete_id
print "Check the synchronizer and both ledger copies before retrying."
goto end-script

:child-id-error:
print "Removal stopped: a matching cluster child has no policy ID."
goto end-script

:node-id-error:
print "Removal stopped: a matching node policy has no policy ID."
goto end-script

:ambiguous-name:
print "Refusing removal: node name is ambiguous or has incomplete endpoint/company information: " !rmn_target_name
print "Matching node policies:"
print !rmn_nodes
goto end-script

:ambiguous-child:
print "Cannot determine cluster child ownership for node " !rmn_target_name " - no policies removed."
print "Cluster children requiring review:"
print !rmn_children
goto end-script

:unsynchronized-error:
print "Refusing removal: ledger and local blockchain policy IDs differ, or local-only policies exist."
print "Back up both copies and reconcile them without discarding local policies before retrying."
goto end-script

:master-error:
print "Refusing removal: run this script on a master node with a local ledger."
goto end-script

:no-nodes:
print "No matching node policy in the local blockchain: name=" !rmn_target_name
goto end-script

:self-removal-error:
print "Refusing to remove this master node: " !rmn_target_name
goto end-script

:local-name-error:
print "Refusing removal: the local node name is not set."
goto end-script

:missing-params:
print "Usage: process !local_scripts/sample-scripts/remove_node.al <node_name> <true|false>"

:end-script:
end script

#----------------------------------------------------------------------------------------------------------------------#
# Remove a node of any type (master, operator, publisher, query, generic, relay) from the network, as if it had never
# been registered.
#   Run on the MASTER node (the node holding the ledger), not on the node being removed.
#   Every node policy matching target_name and target_ip is removed from:
#       1. the local blockchain file    - blockchain delete policy where id = ... and local = true
#       2. the master ledger            - blockchain drop policy where id = ...
#   Cluster child policies (parent = cluster id) published from the node's IP are removed too. Children published
#   by other nodes stay, so the cluster policy stays while any other child references it.
#   The config, orchestrator and cluster policies referenced by the node policy are removed only when
#   no other policy in the ledger still references them (they can be shared with other nodes).
#   Other policies issued from the node's IP are listed in the dry run for manual review, not removed.
#   Other nodes drop the policies on their next blockchain sync (BLOCKCHAIN_SYNC).
#   The script refuses to remove the node it is running on (node_name).
#   A master node can only be removed from a master node (NODE_TYPE master, master-operator or master-publisher).
#
# Usage - pass the parameters on the process command, in this order (all three are required):
#   process !local_scripts/sample-scripts/remove_node.al <node_name> <node_ip> <confirm>
#   Dry run (lists the matching policies, no changes):
#     process !local_scripts/sample-scripts/remove_node.al anylog-standalone-operator 136.23.47.189 false
#   Apply the removal:
#     process !local_scripts/sample-scripts/remove_node.al anylog-standalone-operator 136.23.47.189 true
#----------------------------------------------------------------------------------------------------------------------#
variables(target_name, target_ip, confirm)
on error ignore

set last_policy_id = none
set last_child_id = none

if not !target_name then goto missing-params
if not !target_ip then goto missing-params
if !target_name == !node_name then goto self-removal-error

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
goto remove-children

:removal-done:
node_count = blockchain get (master,operator,publisher,query,generic,relay) where name = !target_name and ip = !target_ip bring.count
if !node_count then goto removal-stuck
print "Node removed from the network: name=" !target_name " ip=" !target_ip
goto end-script

:removal-stuck:
print "Could not remove all node policies for name=" !target_name " ip=" !target_ip " - check the ledger and local blockchain file"
goto end-script

:dry-run:
print "Dry run - no changes made. Re-run with confirm = true as the last parameter to apply the removals listed below."
policy_id = blockchain get (master,operator,publisher,query,generic,relay) where name = !target_name and ip = !target_ip bring.first [*][id]
config_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][config]
orchestrator_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][orchestrator]
cluster_id = blockchain get (master,operator,publisher,query,generic,relay) where id = !policy_id bring.first [*][cluster]
if not !cluster_id then goto check-config
print "Cluster child policies published from ip " !target_ip " (removed when confirm = true):"
child_entries = blockchain get cluster where parent = !cluster_id and [source] contains !target_ip bring [*][id] separator = ,
print "Child entries: " !child_entries
goto check-config

# Child cluster policies are removed one at a time, then the loop re-counts until none are left
:remove-children:
if not !cluster_id then goto check-config
child_count = blockchain get cluster where parent = !cluster_id and [source] contains !target_ip bring.count
if not !child_count then goto check-config
if !child_count == 0 then goto check-config
child_policy_id = blockchain get cluster where parent = !cluster_id and [source] contains !target_ip bring.first [*][id]
if not !child_policy_id then goto check-config
if !child_policy_id == !last_child_id then print "Could not remove cluster child policy id: " !child_policy_id " - check the ledger and local blockchain file"
if !child_policy_id == !last_child_id then goto check-config
set last_child_id = !child_policy_id
blockchain delete policy where id = !child_policy_id and local = true
blockchain drop policy where id = !child_policy_id
blockchain reload metadata
print "Removed cluster child policy id: " !child_policy_id " (published from ip " !target_ip ")"
goto remove-children

# An empty count is treated as still referenced (ref_count != 0), so nothing is dropped on a failed query
:check-config:
if not !config_id then goto check-orchestrator
ref_count = blockchain get (master,operator,publisher,query,generic,relay) where config = !config_id and id != !policy_id bring.count
if !ref_count != 0 then print "Keep config policy - still used by other policies: " !config_id
if !ref_count == 0 then print "Config policy not used by other policies: " !config_id
if !ref_count == 0 and !confirm == true then blockchain drop policy where id = !config_id

:check-orchestrator:
if not !orchestrator_id then goto check-cluster
ref_count = blockchain get (master,operator,publisher,query,generic,relay) where orchestrator = !orchestrator_id and id != !policy_id bring.count
if !ref_count != 0 then print "Keep orchestrator policy - still used by other policies: " !orchestrator_id
if !ref_count == 0 then print "Orchestrator policy not used by other policies: " !orchestrator_id
if !ref_count == 0 and !confirm == true then blockchain drop policy where id = !orchestrator_id

:check-cluster:
if not !cluster_id then goto after-checks
ref_count = blockchain get (master,operator,publisher,query,generic,relay) where cluster = !cluster_id and id != !policy_id bring.count
all_children = blockchain get cluster where parent = !cluster_id bring.count
own_children = blockchain get cluster where parent = !cluster_id and [source] contains !target_ip bring.count
# Child policies published by other nodes under the same root still reference it
if !all_children != !own_children then set ref_count = 1
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
print "Usage: process !local_scripts/sample-scripts/remove_node.al <node_name> <node_ip> <confirm>"

:end-script:
end script

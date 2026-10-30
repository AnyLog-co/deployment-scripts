# Remove a node from an isolated demo master's ledger.
#
# Usage:
#   process !local_scripts/sample-scripts/demo_remove_node.al <node_name> false
#   process !local_scripts/sample-scripts/demo_remove_node.al <node_name> true
#
# Stop the target and other policy writers, synchronize the master's local
# blockchain with its ledger, and back up both before applying. This script
# does not check whether the two copies are synchronized. It refreshes the
# local blockchain from the ledger, which discards local-only policies.
#
# A child is selected when its source matches the node policy's ip or local_ip
# and port. This assumes endpoints have not been reused. Children using another
# or an older endpoint are not removed; review the dry run before applying.
# Shared config, orchestrator and cluster policies are kept. When a node has
# multiple policies, dependencies can become removable later in the same run.
# A table policy is removed only when every cluster child that lists the table
# belongs to the removed node; tables also served by another node are kept.
# Target data is not removed. If a command fails, earlier deletions are not
# rolled back; reconcile the ledger and local blockchain before retrying.

variables(drm_name, drm_confirm)
on error end script

if not !drm_name then goto usage
if !drm_confirm != true and !drm_confirm != false then goto usage
if not !node_name then goto local-name-error
if !drm_name == !node_name then goto self-error
if $NODE_TYPE != master and $NODE_TYPE != master-operator and $NODE_TYPE != master-publisher then goto master-error

blockchain reload metadata
drm_nodes = blockchain get (master,operator,publisher,query,generic,relay) where name = !drm_name
if not !drm_nodes then goto no-nodes
drm_node_count = from !drm_nodes bring.count
set drm_node_index = 0
if !drm_confirm == false then print "Dry run; no policies will be removed."

:next-node:
if !drm_node_index.int >= !drm_node_count.int then goto done
drm_node_id = from !drm_nodes(!drm_node_index) bring [*][id]
drm_config_id = from !drm_nodes(!drm_node_index) bring [*][config]
drm_orchestrator_id = from !drm_nodes(!drm_node_index) bring [*][orchestrator]
drm_cluster_id = from !drm_nodes(!drm_node_index) bring [*][cluster]
drm_ip = from !drm_nodes(!drm_node_index) bring [*][ip]
drm_local_ip = from !drm_nodes(!drm_node_index) bring [*][local_ip]
drm_port = from !drm_nodes(!drm_node_index) bring [*][port]
if not !drm_node_id then goto missing-id
print "Node policy: " !drm_node_id

set drm_match_count = 0
set drm_source = ""
set drm_local_source = ""
if !drm_ip and !drm_port then drm_source = "Node at " + !drm_ip + ":" + !drm_port
if !drm_local_ip and !drm_port then drm_local_source = "Node at " + !drm_local_ip + ":" + !drm_port
if not !drm_cluster_id then goto check-config
if not !drm_source and not !drm_local_source then print "No node endpoint; cluster children will be kept."
drm_children = blockchain get cluster where parent = !drm_cluster_id
if not !drm_children then goto check-config
drm_child_count = from !drm_children bring.count
set drm_child_index = 0
if not !drm_source and not !drm_local_source then goto next-child

# Table policies are shared by dbms.table name. They are evaluated before any
# cluster child is dropped: a table is removed only when every cluster child
# that lists it is owned by this node (matched by source).
drm_tables = blockchain get table
if not !drm_tables then goto next-child
drm_table_count = from !drm_tables bring.count
set drm_table_index = 0

:next-table:
if !drm_table_index.int >= !drm_table_count.int then goto next-child
drm_table_id = from !drm_tables(!drm_table_index) bring [*][id]
drm_table_dbms = from !drm_tables(!drm_table_index) bring [*][dbms]
drm_table_name = from !drm_tables(!drm_table_index) bring [*][name]
drm_table_index = incr !drm_table_index 1
if not !drm_table_id or not !drm_table_dbms or not !drm_table_name then goto next-table
drm_table_refs = blockchain get cluster where [table][dbms] = !drm_table_dbms and [table][name] = !drm_table_name bring.count
if not !drm_table_refs then goto next-table
set drm_table_mine = 0
set drm_table_local = 0
if !drm_source then drm_table_mine = blockchain get cluster where parent = !drm_cluster_id and source = !drm_source and [table][dbms] = !drm_table_dbms and [table][name] = !drm_table_name bring.count
if !drm_local_source and !drm_local_source != !drm_source then drm_table_local = blockchain get cluster where parent = !drm_cluster_id and source = !drm_local_source and [table][dbms] = !drm_table_dbms and [table][name] = !drm_table_name bring.count
if not !drm_table_mine then set drm_table_mine = 0
if not !drm_table_local then set drm_table_local = 0
drm_table_owned = incr !drm_table_mine !drm_table_local
if !drm_table_owned.int == 0 then goto next-table
if !drm_table_owned.int != !drm_table_refs.int then goto keep-table
print "Remove table policy: " !drm_table_id " table: " !drm_table_dbms "." !drm_table_name
if !drm_confirm == true then blockchain drop policy where id = !drm_table_id
goto next-table

:keep-table:
print "Keeping table policy used by another node: " !drm_table_id " table: " !drm_table_dbms "." !drm_table_name
goto next-table

:next-child:
if !drm_child_index.int >= !drm_child_count.int then goto check-config
drm_child_id = from !drm_children(!drm_child_index) bring [*][id]
drm_child_source = from !drm_children(!drm_child_index) bring [*][source]
if not !drm_child_id then goto missing-child-id
if not !drm_child_source then goto keep-child
if !drm_source and !drm_child_source == !drm_source then goto match-child
if !drm_local_source and !drm_child_source == !drm_local_source then goto match-child

:keep-child:
print "Keeping cluster child: " !drm_child_id " source: " !drm_child_source
goto child-done

:match-child:
print "Remove cluster child: " !drm_child_id " source: " !drm_child_source
drm_match_count = incr !drm_match_count 1
if !drm_confirm == true then blockchain drop policy where id = !drm_child_id

:child-done:
drm_child_index = incr !drm_child_index 1
goto next-child

:check-config:
if not !drm_config_id then goto check-orchestrator
drm_refs = blockchain get * where config = !drm_config_id bring.count
drm_other_refs = blockchain get * where orchestrator = !drm_config_id bring.count
drm_cluster_refs = blockchain get * where cluster = !drm_config_id bring.count
drm_parents = blockchain get * where parent = !drm_config_id bring.count
if !drm_refs != 1 or !drm_other_refs or !drm_cluster_refs or !drm_parents then goto keep-config
drm_exists = blockchain get config where id = !drm_config_id
if not !drm_exists then goto check-orchestrator
print "Remove config policy: " !drm_config_id
if !drm_confirm == true then blockchain drop policy where id = !drm_config_id
goto check-orchestrator

:keep-config:
print "Config still referenced; it may become removable later: " !drm_config_id

:check-orchestrator:
if not !drm_orchestrator_id then goto check-cluster
drm_refs = blockchain get * where orchestrator = !drm_orchestrator_id bring.count
drm_other_refs = blockchain get * where config = !drm_orchestrator_id bring.count
drm_cluster_refs = blockchain get * where cluster = !drm_orchestrator_id bring.count
drm_parents = blockchain get * where parent = !drm_orchestrator_id bring.count
if !drm_refs != 1 or !drm_other_refs or !drm_cluster_refs or !drm_parents then goto keep-orchestrator
drm_exists = blockchain get orchestrator where id = !drm_orchestrator_id
if not !drm_exists then goto check-cluster
print "Remove orchestrator policy: " !drm_orchestrator_id
if !drm_confirm == true then blockchain drop policy where id = !drm_orchestrator_id
goto check-cluster

:keep-orchestrator:
print "Orchestrator still referenced; it may become removable later: " !drm_orchestrator_id

:check-cluster:
if not !drm_cluster_id then goto remove-node
drm_refs = blockchain get * where cluster = !drm_cluster_id bring.count
drm_other_refs = blockchain get * where config = !drm_cluster_id bring.count
drm_orchestrator_refs = blockchain get * where orchestrator = !drm_cluster_id bring.count
drm_parents = blockchain get * where parent = !drm_cluster_id bring.count
if !drm_refs != 1 or !drm_other_refs or !drm_orchestrator_refs then goto keep-cluster
if !drm_parents and !drm_parents.int != !drm_match_count.int then goto keep-cluster
drm_exists = blockchain get cluster where id = !drm_cluster_id
if not !drm_exists then goto remove-node
print "Remove cluster policy: " !drm_cluster_id
if !drm_confirm == true then blockchain drop policy where id = !drm_cluster_id
goto remove-node

:keep-cluster:
print "Cluster still referenced; it may become removable later: " !drm_cluster_id

:remove-node:
print "Remove node policy: " !drm_node_id
if !drm_confirm == false then goto node-done
blockchain drop policy where id = !drm_node_id
blockchain pull to json
blockchain update file
drm_exists = blockchain read (master,operator,publisher,query,generic,relay) where id = !drm_node_id
if !drm_exists then goto refresh-error
blockchain reload metadata
print "Removed node policy and refreshed the local blockchain: " !drm_node_id

:node-done:
drm_node_index = incr !drm_node_index 1
goto next-node

:done:
if !drm_confirm == false then print "Review the proposed deletions and any kept children before applying."
else print "Demo node removal completed: " !drm_name
goto end-script

:missing-id:
print "Removal stopped: a matching node policy has no ID."
goto end-script

:missing-child-id:
print "Removal stopped: a cluster child has no ID; earlier deletions may have succeeded."
goto end-script

:refresh-error:
print "Removal stopped: the node policy remains in the local blockchain after refresh."
print "Reconcile the ledger and local blockchain before retrying."
goto end-script

:no-nodes:
print "No matching node policy: " !drm_name
goto end-script

:self-error:
print "Refusing to remove this master node: " !drm_name
goto end-script

:local-name-error:
print "Refusing removal: the local node name is not set."
goto end-script

:master-error:
print "Refusing removal: run this script on a master node with a local ledger."
goto end-script

:usage:
print "Usage: process !local_scripts/sample-scripts/demo_remove_node.al <node_name> <true|false>"

:end-script:
end script

#----------------------------------------------------------------------------------------------------------------
# Deploy database(s) based on node type and configuration
# -- for operator also deploy partitions if set
#----------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/deploy_database.al

on error ignore

if !node_type == master or !master_configs == true then process !local_scripts/database/configure_dbms_blockchain.al

if !node_type == publisher or !node_type == operator then process !local_scripts/database/configure_dbms_almgm.al

if !node_type == operator then
do process !local_scripts/database/configure_dbms_operator.al
do process !local_scripts/database/configure_blob_storage.al


if !node_type == query or !system_query == true then !local_scripts/database/connect_dbms_system_query.al



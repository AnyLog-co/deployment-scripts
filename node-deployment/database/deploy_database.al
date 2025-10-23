#----------------------------------------------------------------------------------------------------------------
# Deploy database(s) based on node type and configuration
# -- for operator also deploy partitions if set
#----------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/deploy_database.al
on error ignore
if !debug_mode == true then set debug on

if $NODE_TYPE == operator then goto operator-dbms
if $NODE_TYPE == publisher then goto almgm-dbms
if $NODE_TYPE == query then goto system-query-dbms

:master-dbms:
if !debug_mode == true then print "Blockchain related database processes"
process !local_scripts/database/configure_dbms_blockchain.al
if $NODE_TYPE == master-publisher then goto almgm-dbms
else if !system_query == true then goto system-query-dbms
else if $NODE_TYPE == master then goto end-script

:operator-dbms:
if !debug_mode == true then print "Operator related database processes"
process !local_scripts/database/configure_dbms_operator.al
process !local_scripts/database/configure_blob_storage.al

:almgm-dbms:
if !debug_mode == true then print "almgm related database processes"
process !local_scripts/database/configure_dbms_almgm.al

:system-query-dbms:
if !debug_mode == true then print "system_query database processes"
if !node_type == query or !system_query == true then process !local_scripts/database/configure_dbms_system_query.al


# :blockchain-sync:
# if !debug_mode == true then print "set blockchain sync"

# on error call blockchain-sync-error

set debug off
:end-script:
end script

:terminate-scripts:
exit scripts

:blockchain-sync-error:
echo "failed to to declare blockchain sync process"
goto terminate-scripts



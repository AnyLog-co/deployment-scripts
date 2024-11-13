#----------------------------------------------------------------------------------------------------------------
# Deploy database(s) based on node type and configuration
# -- for operator also deploy partitions if set
#----------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/deploy_database.al

on error ignore
if !debug_mode == true then set debug on

if !node_type == operator or $NODE_TYPE == master-operator then goto  operator-dbms
else if !node_type == publisher or $NODE_TYPE == master-publisher then goto  almgm-dbms
else if !node_type == query then goto system-query-dbms

:master-dbms:
if !debug_mode == true then print "Blockchain related database processes"
process !local_scripts/database/configure_dbms_blockchain.al
goto system-query-dbms

:operator-dbms:
if !debug_mode == true then print "Operator related database processes"
process !local_scripts/database/configure_dbms_operator.al
process !local_scripts/database/configure_dbms_nosql.al

:almgm-dbms:
if !debug_mode == true then print "almgm related database processes"
process !local_scripts/database/configure_dbms_almgm.al

:system-query-dbms:
if !node_type != query and !deploy_system_query != true then goto end-script
if !debug_mode == true then print "system_query database processes"
else process !local_scripts/database/configure_dbms_system_query.al

:end-script:
end script
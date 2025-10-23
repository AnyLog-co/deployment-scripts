#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for blockchain logical database
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_almgm.al

on error ignore
:connect-dbms:
set db_name = blockchain
process !local_scripts/database/connect_dbms_sql.al

:create-table:
on error goto almgm-table-error
is_table = info table blockchain ledger exists
if !is_table == false then create table ledger where dbms=blockchain


:end-script:
end script

:terminate-scripts:
exit scripts


:blockchain-table-error:
echo "Error: Failed to create table blockchain.ledger. Cannot continue"
goto terminate-scripts
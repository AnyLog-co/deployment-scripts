#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for blockchain logical database
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/database/configure_dbms_almgm.al

on error ignore
:connect-dbms:
set db_name = blockchain
process !local_scripts/node-deployment/database/connect_dbms_sql.al

:create-table:
# If blockchain logical database DNE then create it  (ie first time)
# If blockchain logical file does exist then pull a copy of the blockchain

on error goto almgm-table-error

is_table = info table blockchain ledger exists
is_file = file test !blockchain file

if !is_table == false then create table ledger where dbms=blockchain

else if !is_file == false then
do blockchain pull to json !blockchain_file
do blockchain reload metadata


:end-script:
end script

:terminate-scripts:
exit scripts


:blockchain-table-error:
echo "Error: Failed to create table blockchain.ledger. Cannot continue"
goto terminate-scripts

#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for blockchain logical database
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/database/configure_dbms_blockchain.al

on error ignore
:set-debug:
if !enable_debug == true then set debug on

:connect-dbms:
set db_name = blockchain
process !local_scripts/node-deployment/database/connect_dbms_sql.al

:create-table:
on error goto almgm-table-error
is_table = info table blockchain ledger exists
if !is_table == false then create table ledger where dbms=blockchain

:extract-data:
sql_count = sql blockchain format=json:list and stat=false select count(*) as count  from ledger
serialized_count = python !sql_count.replace('[', '').replace(']', '')
row_count = from !serialized_count bring [count]

if !row_count != 0 then
do blockchain pull to json
do blockchain update file
do blockchain reload metadata

:end-script:
end script

:terminate-scripts:
exit scripts


:blockchain-table-error:
echo "Error: Failed to create table blockchain.ledger. Cannot continue"
goto terminate-scripts

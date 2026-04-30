#----------------------------------------------------------------------------------------------------------------------#
# Connect to an actual blockchain as opposed to connecting to an AnyLog master
#   --> validate keys and credentials exists are set
#   --> declare / connect to blockchain account
#   --> set contract
#   --> set account
#   --> sync from contract
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/connect_blockchain.al

on error ignore

if !blockchain_source == master then goto blockchain-sync

:blockchain-connect:
on error goto connect-blockchain-account-error
blockchain connect to optimism where provider=https://optimism-sepolia.infura.io/v3/532f565202744c0cb7434505859efb74

:declare-blockchain-account:
on error goto declare-blockchain-account-error
<blockchain set account info where
    platform = !blockchain_source and
    private_key = !blockchain_private_key and
    public_key = !blockchain_public_key and
    chain_id = !chain_id>

if !contract then goto blockchain-account

:create-contract:

is_policy = blockchain get blockchain-info where company=!company_name and public_key=!blockchain_public_key and chain_id=!chain_id
if !is_policy then contract = from !is_policy bring [*][contract]

if not !contract then
do on error goto create-contract-error
do contract = blockchain deploy contract where  platform = !blockchain_source and public_key = !blockchain_public_key
do print "New Contract created: " !contract " - make sure to save contract / update config file accordingly"

:blockchain-account:

on error goto blockchain-account-error
blockchain set account info where platform = !blockchain_source and contract = !contract

:blockchain-sync:
on error goto blockchain-sync-error
if !blockchain_source == optimism then
do print !contract
<do run blockchain sync where
    source=blockchain and
    time=!blockchain_sync and
    dest=!blockchain_destination and
    platform=!blockchain_source>
do process !local_scripts/node-deployment/policies/blockchain_policy.al
do get platforms
else if !blockchain_source == master then
<do run blockchain sync where
    source=!blockchain_source and
    time=!blockchain_sync and
    dest=!blockchain_destination and
    connection=!ledger_conn>

goto end-script

:end-script:
end script

:terminate-scripts:
exit scripts

:connect-blockchain-account-error:
print "Failed to connect to Optimism"
goto terminate-scripts

:create-contract-error
print "Failed to create new contract"
goto terminate-scripts

:declare-blockchain-account-error:
print "Failed to declare account information, cannot continue..."
goto  terminate-scripts

:blockchain-sync-error:
echo "Failed to initiate scheduled blockchain sync"
goto end-script

:blockchain-seed-error:
echo Failed to execute blockchain sync agaisnt !ledger_conn
goto end-script




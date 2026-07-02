#----------------------------------------------------------------------------------------------------------------------#
# node name generator if $NODE_NAME not provided
# :logic:
#   if !node_type == operator then check if there's already a policy with the same cluster ID
#   if yes - add a backup operator
#   if no / !node_type != operator - then check number of nodes (not backup) of the same type
# :naming-logic:
#   master
#       acme-master1
#   query
#       acme-query1
#       acme-query2
#   operator
#       acme-operator1, acme-operator1-bkup1, acme-operator1-bkup2
#       acme-operator2, acme-operator2-bkup1
#       acme-operator3
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/policies/node_name.al

set debug on

:node-count:
on error ignore

if !node_type != operator or not !cluster_id then policy_count = blockchain get !node_type where company=!company_name bring.count
if !cluster_id then policy_count = blockchain get !node_type where cluster=!cluster_id bring.count

if !policy_count then
do inc_policy_count = python !policy_count.int + 1
do set policy_count = !inc_policy_count

if not !policy_count then policy_count = 1

if !cluster_id then goto node-name-operator-bkup

:node-name:

node_name = !node_hostname + "-" + !node_company_name + "-" + !node_type + !policy_count
goto set-node-name

:node-name-operator-bkup:
basename = blockchain get !node_type where cluster = !cluster_id and main = true bring.first [*][name]
if not !basename then goto node-name
node_name = !basename + "-bkup" + !policy_count

goto set-node-name

:set-node-name:
set node name !node_name

:end-script:
set debug off
end script

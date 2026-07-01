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

:set-params:
on error ignore

:node-name:
# not operator node define policies
if !cluster_id then policy_count = blockchain get !node_type where cluster = !cluster_id bring.count
else policy_count = blockchain get !node_type where company = !company_name bring.count

if !policy_count then
do tmp_policy_count = python !policy_count.int + 1
do set policy_count = !tmp_policy_count
else policy_count = 1

node_name = !node_hostname + "-" + !node_company_name + "-" + !node_type + !policy_count
goto set-node-name

:node-name-operator:
policy_count  = blockchain get !node_type where company = !company_name and main = true  bring.count
if !policy_count then policy_count = python !policy_count.int + 1
else policy_count = 1

node_name = !node_hostname + "-" + !node_company_name + "-operator" + !policy_count
goto set-node-name

:node-name-operator-bkup:
# backup operator
basename      = blockchain get !node_type where cluster = !cluster_id and main = true bring.first [*][name]
policy_count  = blockchain get !node_type where cluster = !cluster_id and main = false bring.count
if !policy_count then policy_count = python !policy_count.int + 1
else policy_count = 1

node_name  = !basename + "-bkup" + !policy_count

goto set-node-name

:set-node-name:
set node name !node_name

:end-script:
end script
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

if !node_type != operator then goto node-name

policy_count = blockchain get !node_type where cluster = !cluster_id bring.count
if not !policy_count then goto node-name-operator
else goto node-name-operator-bkup

:node-name:
# not operator node define policies
policy_count = blockchain get !node_type where company = !company_name bring.count
if !policy_count then policy_count = python !policy_count.int + 1
else policy_count = 1

node_name = !node_hostname + "-" + !node_company_name + "-" + !node_type + !policy_count
goto set-node-name

:node-name-operator:
total_count  = blockchain get !node_type where company = !company_name bring.count
bkup_count   = blockchain get !node_type where company = !company_name and [name] contains "bkup" bring.count

if !total_count and !bkup_count then policy_count = python !total_count.int - !bkup_count.int
else if !total_count then policy_count = !total_count
else policy_count = 0

policy_count = python !policy_count.int + 1
node_name = !node_hostname + "-" + !node_company_name + "-operator" + !policy_count
goto set-node-name

:node-name-operator-bkup:
# backup operator
basename      = blockchain get !node_type where cluster = !cluster_id bring.first [*][name]
policy_count  = blockchain get !node_type where cluster = !cluster_id and [name] contains "bkup" bring.count
if !policy_count then policy_count = python !policy_count.int + 1
else policy_count = 1

node_name = !basename + "-bkup" + !policy_count

goto set-node-name

:set-node-name:
set node name !node_name

:end-script:
end script
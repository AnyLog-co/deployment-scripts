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

on error ignore

:set-debug:
set debug on
if !enable_debug == true then set debug on

if !node_type == operator and not !cluster_name then goto cluster-name
else if !node_name then goto end-script

rand_int = random int

:cluster-name:
if !cluster_id then cluster_name = blockchain get cluster where id = !cluster_id bring.first [*][name]
else if $CLUSTER_NAME and not !cluster_name then cluster_name = $CLUSTER_NAME
else if not $CLUSTER_NAME and not !cluster_name then cluster_name = "cluster-" + !node_hostname + "-" + !node_company_name + "-" + !node_type + "-" + !rand_int

:node-name:
if $NODE_NAME and not !node_name then node_name = $NODE_NAME
else if not !node_name and not $NODE_NAME then node_name = !node_hostname + "-" + !node_company_name + "-" + !node_type + "-" + !rand_int

:set-node-name:
if not !set_node_name or !set_node_name != true then
do set node name !node_name
do set set_node_name = true

:end-script:
if !enable_debug == true then set debug off
set debug off
end script

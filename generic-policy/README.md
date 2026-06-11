# No Script Deployment logic

The following directory provides examples for using 100% policies rather than policies referencing scripts 

## Logical Script 

1. declare [master_policy.al](master_policy.al) if DNE
2. execute master (config) policy 
3. based on node type + whether policy exists 


## Issues 

1. Env params 
Right now we do not have a logic make dictionary content persistent. This means the code needs to reread the 
configuration file every time, a small change could cause something to break

2. `FOR` loop  
There needs to be a logic to allow for multiple configs to be run for the node.

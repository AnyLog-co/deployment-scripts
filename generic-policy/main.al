is_params = file test !data_dir/env_params.json
if !is_params == false then
do process set_params.al
do save env params where dest = !data_dir/env_params.json
else load env params where dest = !data_dir/env_params.json

is_policy = blockchain get config where id = master-configs
if not !is_policy then process master_policy.al
else config from policy where id = master-configs
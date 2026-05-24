{
    "config": {
        "id": "master-policy",
        "script": [
            "if !node_type == master    then file_path = blockchain_node.al",
            "if !node_type == query     then file_path = query_node.al",
            "if !node_type == operator  then file_path = operator_node.al",
            "if !node_type == publisher then file_path = publisher_node.al",
            "policy_id = blockchain get config where node_type == !node_type [*][id]",
            "is_file = test file !file_path",
            "if not !policy_id and !is_file == false then print 'Error: Missing config info' && exist scripts",
            "run scheduler 1",
            "if not !policy_id and !is_file == true then process !file_path",
            "if !policy_id then config from policy where id = !policy_id"
        ]
    }
}
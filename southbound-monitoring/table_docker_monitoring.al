#-----------------------------------------------------------------------------------------------------------------------
# Table blockchain table policy for monitoring
#   -> create table policy
#   -> connect to database + create table
#   -> create 12 hrs partitioning
# :sample table:
# CREATE TABLE IF NOT EXISTS node_insight(
#   row_id INTEGER PRIMARY KEY AUTOINCREMENT,
#   insert_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
#   tsd_name CHAR(3),
#   tsd_id INT,
#   node_name varchar,
#   status varchar,
#   operational_time TIME ,
#   processing_time TIME ,
#   elapsed_time TIME ,
#   new_rows INT,
#   total_rows INT,
#   new_errors INT,
#   total_errors INT,
#   avg_rows_sec FLOAT,
#   timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
#   node_type char(9) NOT NULL default 'generic',
#   free_space_percent FLOAT,
#   cpu_percent FLOAT,
#   packets_recv INT,
#   packets_sent INT,
#   network_error INT
# );
# CREATE INDEX node_insight_timestamp_index ON node_insight(timestamp);
# CREATE INDEX node_insight_tsd_index ON node_insight(tsd_name, tsd_id);
# CREATE INDEX node_insight_insert_timestamp_index ON node_insight(insert_timestamp);
# CREATE INDEX node_insight_node_name_index ON node_insight(node_name);
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/southbound-monitoring/table_docker_monitoring.al
on error ignore

set debug interactive

set create_policy = false

:check-policy:

on error ignore
is_table = blockchain get table where dbms=monitoring and name=docker_insight
if !is_table then goto end-script
if not !is_table and !create_policy == true then goto declare-policy-error

:prep-policy:
create_stmt = "CREATE TABLE IF NOT EXISTS docker_insight( row_id SERIAL PRIMARY KEY, insert_timestamp TIMESTAMP NOT NULL, tsd_name CHAR(3), tsd_id INT, hostname VARCHAR, container VARCHAR, created TIMESTAMP, timestamp TIMESTAMP NOT NULL, uptime TEXT, memory_usage_bytes BIGINT, disk_read_bytes BIGINT, disk_write_bytes BIGINT, network_rx_packets INT, network_tx_packets INT, user_id INT, process_id INT, parent_process_id INT, cpu_usage FLOAT, start_time CHAR(5), terminal CHAR(5), cpu_time TEXT, command VARCHAR ); CREATE INDEX docker_insight_timestamp_index ON docker_insight(timestamp); CREATE INDEX docker_insight_tsd_index ON docker_insight(tsd_name, tsd_id); CREATE INDEX docker_insight_insert_timestamp_index ON docker_insight(insert_timestamp); CREATE INDEX docker_insight_hostname_index ON docker_insight(hostname);"

<new_policy = {
    "table": {
        "dbms": "monitoring",
            "name": "docker_insight",
        "create": !create_stmt
    }
}>


:publish-policy:

set is_node_policy = true
process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
set is_node_policy = false

wait 5
goto check-policy

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare cluster policy on blockchain"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts

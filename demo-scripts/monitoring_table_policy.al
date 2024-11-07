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
#   operational_time TIME NOT NULL DEFAULT '00:00:00',
#   processing_time TIME NOT NULL DEFAULT '00:00:00',
#   elapsed_time TIME NOT NULL DEFAULT '00:00:00',
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
# process !anylog_path/deployment-scripts/demo-scripts/monitoring_table_policy.al
on error ignore

set create_table = false
:check-table-policy:
is_table = blockchain get table where dbms=monitoring and name=node_insight
if !is_table then goto dbms-configs
else if not !is_table and !create_table == true then goto declare-policy-error

:declare-policy:
<new_policy = {
    "table": {
        "dbms": "monitoring",
        "name": "node_insight",
        "create": "CREATE TABLE IF NOT EXISTS node_insight( row_id INTEGER PRIMARY KEY AUTOINCREMENT, insert_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, tsd_name CHAR(3), tsd_id INT, node_name varchar, status varchar, operational_time TIME NOT NULL DEFAULT '00:00:00', processing_time TIME NOT NULL DEFAULT '00:00:00', elapsed_time TIME NOT NULL DEFAULT '00:00:00', new_rows INT, total_rows INT, new_errors INT, total_errors INT, avg_rows_sec FLOAT, timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, node_type char(9) NOT NULL default 'generic', free_space_percent FLOAT, cpu_percent FLOAT, packets_recv INT, packets_sent INT, network_error INT ); CREATE INDEX node_insight_timestamp_index ON node_insight(timestamp); CREATE INDEX node_insight_tsd_index ON node_insight(tsd_name, tsd_id); CREATE INDEX node_insight_insert_timestamp_index ON node_insight(insert_timestamp); CREATE INDEX node_insight_node_name_index ON node_insight(node_name);"
    }
}>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error
set create_table = true
goto check-table-policy

:dbms-configs:
on error goto dbms-config-error
connect dbms monitoring where type=sqlite

on error call partition-config-error
partition monitoring node_insight using timestamp by 12 hours

on error goto table-config-error
create table node_insight where dbms=monitoring

:end-script:
end script

:sign-policy-error:
print "Failed to sign cluster policy"
goto end-script

:prepare-policy-error:
print "Failed to prepare member cluster policy for publishing on blockchain"
goto end-script

:declare-policy-error:
print "Failed to declare cluster policy on blockchain"
goto end-script

:dbms-config-error:
echo "Failed to connect to to monitoring database"
goto end-script

:partition-config-error:
echo "Failed to set 12 hour partition intervals - will store data on 1 table"
goto end-script

:table-config-error:
echo "Failed to create monitoring table - autogenerated table will be used instead"
goto end-script
#-----------------------------------------------------------------------------------------------------------------------
# Table blockchain table policy for syslog
#   -> create table policy
#   -> if operator then: connect dbms (monitoring), create table, set partitioning
# :sample table:
#  CREATE TABLE IF NOT EXISTS syslog(
#    row_id SERIAL PRIMARY KEY,
#    insert_timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
#    tsd_name CHAR(3),
#    tsd_id INT,
#    source_ip cidr,
#    priority int,
#    timestamp timestamp not null default now(),
#    hostname varchar,
#    tag varchar,
#    message varchar
# );
# CREATE INDEX syslog_timestamp_index ON syslog(timestamp);
# CREATE INDEX syslog_tsd_index ON syslog(tsd_name, tsd_id);
# CREATE INDEX syslog_insert_timestamp_index ON syslog(insert_timestamp);
# CREATE INDEX syslog_source_ip_index ON syslog(source_ip);
#-----------------------------------------------------------------------------------------------------------------------
# process  !anylog_path/deployment-scripts/southbound-monitoring/create_syslog_monitoring_table.al

on error ignore
set create_table = false

:check-table-policy:
is_table = blockchain get table where dbms=monitoring and name=syslog
if !is_table then goto end-script
else if not !is_table and !create_table == true then goto declare-policy-error

:declare-policy:
<new_policy = {
    "table": {
        "dbms": "monitoring",
        "name": "syslog",
        "create": "CREATE TABLE IF NOT EXISTS syslog(row_id SERIAL PRIMARY KEY,insert_timestamp TIMESTAMP NOT NULL DEFAULT NOW(),tsd_name CHAR(3),tsd_id INT,source_ip cidr,priority int,timestamp timestamp not null default now(),hostname varchar,tag varchar,message varchar);CREATE INDEX syslog_timestamp_index ON syslog(timestamp);CREATE INDEX syslog_tsd_index ON syslog(tsd_name, tsd_id);CREATE INDEX syslog_insert_timestamp_index ON syslog(insert_timestamp);CREATE INDEX syslog_source_ip_index ON syslog(source_ip);"
    }
}>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-table-policy

if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

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
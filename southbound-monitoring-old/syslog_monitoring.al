#----------------------------------------------------------------------------------------------------------------------#
# Accept data from a local rsyslog (into operataor)
#:prepare:
#   1. Install rsyslog
#       sudo apt-get -y update
#       sudo apt -y install rsyslog
#       sudo service rsyslog start
#
#   2. Update /etc/rsyslog.conf with the following lines:
#
# template(name="MyCustomTemplate" type="string" string="<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag% %msg%\n")
# $IncludeConfig /etc/rsyslog.d/*.conf
# *.* ?remote-incoming-logs
# *.* action(type="omfwd" target="[OPERATOR_IP]" port="[OPERATOR_BROKER_PORT]" protocol="tcp" template="MyCustomTemplate")
#
#   3. Restart rsyslog (service)
#       `sudo service rsyslog restart`
#
#   4. On operator `run msg rule`
#       * this command should be run for each machine sending data
#       * each rule should have a unique name `set msg rule [RULE_NAME] if ...`
#
# :process:
#   1. create table policy if DNE
#   2. connect monitoring database inn SQLite
#   3. set partitions
#   4. run message broker (if not set)
#   5. run message rule
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/connectors/syslog.al
on error ignore

if !debug_mode == true then set debug on

:dbms-configs:
process !anylog_path/deployment-scripts/southbound-monitoring/syslog_monitoring_table.al

:store-monitoring:
if !debug_mode == true then print "Monitoring database and table configurations for syslog"

on error goto partition-data-err
partition monitoring syslog using timestamp by 12 hours
schedule time=12 hours and name="drop syslog partitions" task drop partition where dbms=monitoring and table=syslog and keep=3

:connect-network:
if !debug_mode == true then print "connect to MQTT broker if not set"
on error ignore
conn_info = get connections where format=json
is_msg_broker  = from !conn_info bring [Messaging][external]
if not !anylog_broker_port then anylog_broker_port = 32150
if !is_msg_broker  == 'Not declared' then
do on error goto broker-networking-error
<do run message broker where
    external_ip=!external_ip and external_port=!anylog_broker_port and
    internal_ip=!!overlay_ip and internal_port=!anylog_broker_port and
    bind=!broker_bind and threads=!broker_threads>

:set-syslog:
if !debug_mode == true then print "Run message rule"
on error goto set-syslog-error
<set msg rule syslog_rule if
   ip = !ip
then
   dbms = monitoring  and
   table = syslog and
   extend = ip and
   syslog = true>

:end-script:
end script

:terminate-scripts:
exit scripts

:store-monitoring-error:
print "Failed to store"

:partition-data-err:
print "Error: Failed to set partitioning for default database"
goto terminate-scripts

:broker-networking-error:
print "Error: Failed to connect to Message Broker with IP address - will continue deployment without Message Broker"
do goto terminate-scripts

:set-syslog-error:
print "Error: Filed to declare message rule for data to be accepted"

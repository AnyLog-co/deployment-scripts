#-----------------------------------------------------------------------------------------------------------------------
# run syslog process for operator 2
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

process !local_scripts/demo-scripts/syslog.al

on error call syslog-error

# query 1
syslog_ip = 10.10.1.31
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=23.239.12.151 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# smart-city 1
syslog_ip = 10.10.1.211
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.105.60.50 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# smart-city 2
syslog_ip = 10.10.1.213
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.105.6.90 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# smart-city 3
syslog_ip = 10.10.1.215
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=50.116.4.251 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# syslog 2
syslog_ip = 10.10.1.202
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.105.219.25 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# edgex operator2
syslog_ip = 10.10.1.205
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=139.162.56.87 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# edgex operator 3
syslog_ip = 10.10.1.204
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=23.92.28.183 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# syslog_ip = 10.10.1.33
# rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
# set msg rule !rule_name if ip=!syslog_ip then dbms=monitoring and table=syslog and  extend = ip and syslog=true

:end-script:
end script

:syslog-error:
echo failed to syslog for node !syslog_ip
return

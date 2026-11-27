#-----------------------------------------------------------------------------------------------------------------------
# run syslog process for operator 1
#-----------------------------------------------------------------------------------------------------------------------
on error ignore

process !local_scripts/demo-scripts/syslog.al

on error call syslog-error

# master
syslog_ip = 10.10.1.10
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=45.79.74.39 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# syslog-operator1
syslog_ip = 10.10.1.200
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=69.164.203.68 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# smart-city-operator1-bkup1
syslog_ip = 10.10.1.212
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.233.107.121 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# smart-city 2 bkup 1
syslog_ip = 10.10.1.214
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.105.13.202 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# smart city 3 backup 1
syslog_ip = 10.10.1.216
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.105.112.207 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# edgex operator 1
syslog_ip = 10.10.1.206
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.105.86.168 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# edgex operator 4
syslog_ip = 10.10.1.203
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=172.104.180.110 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

# query 2
syslog_ip = 10.10.1.32
rule_name = blockchain get (master, query, publisher, operator) where ip = !syslog_ip bring [*][name]
set msg rule !rule_name if ip=45.79.18.179 then dbms=monitoring and table=syslog and  extend = ip and syslog=true

:end-script:
end script

:syslog-error:
echo failed to syslog for node !syslog_ip
return

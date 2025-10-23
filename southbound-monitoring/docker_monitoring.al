on error ignore
if !node_type != operator then goto pull-data

:pull-data:
on error pull-data-error
<run scheduled pull
  where name = docker_insights
  and type = docker
  and frequency = 5
  and continuous = true
  and dbms = monitoring
  and table = docker_insight>

if !node_type == operator or !node_type == publisher then goto end-script


# if not !docker_operator then docker_operator = blockchain get operator bring.first [*][ip] : [*][port]
# run client (!docker_operator) file copy !watch_dir/* !!watch_dir
# system mv !watch_dir/* !bkup_dir/

:end-script:
end script

:partition-data-err:
print "Error: Failed to set partitioning for default database"
goto end-script

:pull-data-error:
print "Error occurred during pull-data"
goto end-script


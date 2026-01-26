#--------------------------------------------------------#
# Bottle factory aggregations                            #
#--------------------------------------------------------#
on error ignore
:kpi-aggregation:
<set aggregation where
    dbms=!default_dbms and
    table=* and
    intervals=10 and
    time_column = now() and
    value_column = all() and
    time="1 minute">

<set aggregation ingest where
    dbms=!default_dbms and
    table=* and
	source = false and
	derived = false>

:ingest-data:
<set aggregation ingest where
    dbms=!default_dbms and
    table=* and
	source = true and
	derived = false>

:end-script:
end script
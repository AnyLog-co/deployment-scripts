#------------------------------------------------------------------------------------------------#
# The following provides a simple set of commands to run aggregation against the data            #
# In addition, there's an option save a summary of the data every X time frame, as opposed to    #
# as opposed to all the data as it comes in...                                                   #
#                                                                                                #
# This (sample) code is used with OPC-UA and the default MQTT example, if enabled. The code can  #
# also be used with user-defined data sources if desired. A more comprehensive, python-based     #
# option can be found in deployment-scripts/aggregations                                         #
# URL: https://github.com/AnyLog-co/documentation/blob/master/aggregations.md                    #
#                                                                                                #
# Note: if !enable_aggregations isn't enabled script will not run                                #
#------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/aggregations.al

on error ignore
if !aggregation_policy then config from policy where id = !aggregation_policy
else if not !enable_aggregation then goto end-script

:enable-aggregations:
#-----------------------------------------------------------------------------#
# Aggregation functions summarize streaming data over defined time intervals. #
#-----------------------------------------------------------------------------#
on error goto enable-aggregations-error
<set aggregation where
    dbms=!aggregations_dbms and
    table=!aggregations_table and
    intervals=!aggregations_intervals and
    time=!aggregations_time  and
    time_column=!aggregation_time_column and
    value_column=!aggregation_value_column>


:config-ingestion:
#-----------------------------------------------------------------------------#
#  modify the ingestion frequency of aggregation tables in the local database.#
#-----------------------------------------------------------------------------#
on error call config-ingestion-error
if !enable_ingest_aggregations == true then
<do set aggregation ingest where
    dbms=!aggregations_table and
    table=!aggregations_table and
    source = !ingest_raw_data and
    derived = !ingest_aggregations>
# do get aggregation ingest


#:configure-encoding:
#-----------------------------------------------------------------------------#
#  Apply encoding on the values assigned to each time interval                #
#-----------------------------------------------------------------------------#
on error call configure-encoding-error
if !enable_encoding and !encoding_tolerance then
do set aggregation encoding where
    dbms=!aggregations_dbms and
    table=!aggregations_table and
    value_column=!aggregation_value_column and
    encoding = !encoding_type and
    tolerance = !encoding_tolerance>
else if !enable_encoding then
<do set aggregation encoding where
    dbms=!aggregations_dbms and
    table=!aggregations_table and
    value_column=!aggregation_value_column and
    encoding = !encoding_type>



:end-script:
end script

:enable-aggregations-error:
echo "Failed to initiate aggregations for default logical database"
goto end-script

:config-ingestion-error:
echo "Failed to configure ingestion"
return

:configure-encoding-error:
echo "Failed to configure encoding"
return

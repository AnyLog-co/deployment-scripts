#----------------------------------------------------------------------------------------------------------------------#
# AnyLog Tests generator for aggregate functions - MIN, MAX, AVG, SUM and COUNT with and without WHERE and GROUP BY
# conditions
#----------------------------------------------------------------------------------------------------------------------#
# process !test_dir/altests/generate_aggregate_functions_tests.al

set conn = 139.144.8.104:32148

system mkdir !test_dir/altests/aggregate_functions/

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_aggregate_functions.out and title="Aggregate Summary"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_aggregate_group_string.out and title="Aggregate Summary with GROUP BY string"
    "SELECT device_name, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_aggregate_group_uuid.out and title="Aggregate Summary GROUP BY UUID"
    "SELECT parentelement, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_aggregate_where_timestamp.out and title="Aggregate Summary WHERE timestamp"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999'">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_aggregate_where_timestamp_group_string.out and title="Aggregate Summary WHERE timestamp AND GROUP string"
    "SELECT device_name, MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999' GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_aggregate_where_timestamp_group_uuid.out and title="Aggregate Summary WHERE timestamp AND GROUP UUID"
    "SELECT parentelement, MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999' GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_timestamp_value_where_timestamp_string.out and title="Show Timestamp + Value WHERE timestamp AND string"
    "SELECT timestamp, value FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' and timestamp < '2022-03-01 00:00:00' and device_name='ADVA FSP3000R7' ORDER BY timestamp ASC">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/aggregate_functions/test_single_table_timestamp_value_where_timestamp_uuid.out and title="Show Timestamp + Value WHERE timestamp AND string"
    "SELECT timestamp, value FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' and timestamp < '2022-03-01 00:00:00' and parentelement='62e71893-92e0-11e9-b465-d4856454f4ba' ORDER BY timestamp DESC">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_aggregate_functions.out and title="Aggregate Summary"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_aggregate_group_string.out and title="Aggregate Summary with GROUP BY string"
    "SELECT device_name, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_aggregate_group_uuid.out and title="Aggregate Summary GROUP BY UUID"
    "SELECT parentelement, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_aggregate_where_timestamp.out and title="Aggregate Summary WHERE timestamp"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_aggregate_where_timestamp_group_string.out and title="Aggregate Summary WHERE timestamp AND GROUP string"
    "SELECT device_name, MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999' GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_aggregate_where_timestamp_group_uuid.out and title="Aggregate Summary WHERE timestamp AND GROUP UUID"
    "SELECT parentelement, MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999' GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_timestamp_value_where_timestamp_string.out and title="Show Timestamp + Value WHERE timestamp AND string"
    "SELECT timestamp, value FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' and timestamp < '2022-03-01 00:00:00' and device_name='ADVA FSP3000R7' ORDER BY timestamp ASC">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_timestamp_value_where_timestamp_uuid.out and title="Show Timestamp + Value WHERE timestamp AND string"
    "SELECT timestamp, value FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' and timestamp < '2022-03-01 00:00:00' and parentelement='62e71893-92e0-11e9-b465-d4856454f4ba' ORDER BY timestamp DESC">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_aggregate_functions.out and title="Aggregate Summary"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_aggregate_group_string.out and title="Aggregate Summary with GROUP BY string"
    "SELECT device_name, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_aggregate_group_uuid.out and title="Aggregate Summary GROUP BY UUID"
    "SELECT parentelement, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_aggregate_where_timestamp.out and title="Aggregate Summary WHERE timestamp"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_aggregate_where_timestamp_group_string.out and title="Aggregate Summary WHERE timestamp AND GROUP string"
    "SELECT device_name, MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999' GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_aggregate_where_timestamp_group_uuid.out and title="Aggregate Summary WHERE timestamp AND GROUP UUID"
    "SELECT parentelement, MIN(timestamp) as min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-01-01 00:00:00' AND timestamp <= '2022-12-31 23:59:59.999999' GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_timestamp_value_where_timestamp_string.out and title="Show Timestamp + Value WHERE timestamp AND string"
    "SELECT timestamp, value FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' and timestamp < '2022-03-01 00:00:00' and device_name='ADVA FSP3000R7' ORDER BY timestamp ASC">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/aggregate_functions/test_multi_table_extend_timestamp_value_where_timestamp_uuid.out and title="Show Timestamp + Value WHERE timestamp AND string"
    "SELECT timestamp, value FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' and timestamp < '2022-03-01 00:00:00' and parentelement='62e71893-92e0-11e9-b465-d4856454f4ba' ORDER BY timestamp DESC">



#----------------------------------------------------------------------------------------------------------------------#
# AnyLog Tests generator for period functions
#----------------------------------------------------------------------------------------------------------------------#
# process !test_dir/altests/generate_period_tests.al

on error ignore
set conn = 139.144.8.104:32148

system mkdir !test_dir/altests/period_functions/

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_1second_now.out and title="1 second increments"
    "SELECT device_name, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 1, NOW(), timestamp) group by device_name">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_30second_now.out and title="30 second increments"
    "SELECT parentelement, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 30, NOW(), timestamp) group by parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_1minute_now.out and title="1 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_30minute_now.out and title="30 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 30, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_1hour_now.out and title="1 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_12hour_now.out and title="12 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 12, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_1day.out and title="1 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_7day.out and title="7 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 7, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_15day.out and title="15 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 15, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_30day.out and title="30 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 30, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_1month.out and title="1 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/period_functions/test_single_table_period_3month.out and title="3 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 3, '2022-12-31 00:00:00', timestamp)">


<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1second_now.out and title="1 second increments"
    "SELECT device_name, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 1, NOW(), timestamp) group by device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30second_now.out and title="30 second increments"
    "SELECT parentelement, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 30, NOW(), timestamp) group by parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1minute_now.out and title="1 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30minute_now.out and title="30 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 30, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1hour_now.out and title="1 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_12hour_now.out and title="12 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 12, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1day.out and title="1 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_7day.out and title="7 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 7, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_15day.out and title="15 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 15, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30day.out and title="30 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 30, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1month.out and title="1 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/period_functions/test_multi_table_period_3month.out and title="3 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 3, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1second_now.out and title="1 second increments"
    "SELECT device_name, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 1, NOW(), timestamp) group by device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30second_now.out and title="30 second increments"
    "SELECT parentelement, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 30, NOW(), timestamp) group by parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1minute_now.out and title="1 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30minute_now.out and title="30 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 30, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1hour_now.out and title="1 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_12hour_now.out and title="12 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 12, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1day.out and title="1 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_7day.out and title="7 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 7, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_15day.out and title="15 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 15, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30day.out and title="30 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 30, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1month.out and title="1 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_3month.out and title="3 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 3, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1second_now.out and title="1 second increments"
    "SELECT device_name, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 1, NOW(), timestamp) group by device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30second_now.out and title="30 second increments"
    "SELECT parentelement, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(second, 30, NOW(), timestamp) group by parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1minute_now.out and title="1 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30minute_now.out and title="30 minute increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(minute, 30, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1hour_now.out and title="1 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 1, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_12hour_now.out and title="12 hour increments"
    "SELECT MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(hour, 12, NOW(), timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1day.out and title="1 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_7day.out and title="7 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 7, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_15day.out and title="15 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 15, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_30day.out and title="30 day increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(day, 30, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_1month.out and title="1 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 1, '2022-12-31 00:00:00', timestamp)">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/period_functions/test_multi_table_period_3month.out and title="3 month increments"
    "SELECT MIN(timestamp) as min_ts, MAX(timestamp) as max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE period(month, 3, '2022-12-31 00:00:00', timestamp)">




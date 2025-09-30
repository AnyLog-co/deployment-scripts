#----------------------------------------------------------------------------------------------------------------------#
# AnyLog Tests generator for increments functions
#----------------------------------------------------------------------------------------------------------------------#
# process !test_dir/altests/generate_increment_tests.al

on error ignore 
set conn = 139.144.8.104:32148

system mkdir !test_dir/altests/increments_functions/

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_1second.out and title="1 second increments"
    "SELECT increments(second, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_30second.out and title="30 second increments"
    "SELECT increments(second, 30, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_1minute.out and title="1 minute increments"
    "SELECT increments(minute, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">
#
#<run client (!conn) sql test format=table and stat=false and test=true and
#    file=!test_dir/altests/increments_functions/test_single_table_increments_30minute.out and title="30 minute increments"
#    "SELECT increments(minute, 30, timestamp), device_name, MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00' GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_1hour.out and title="1 hour increments"
    "SELECT increments(hour, 1, timestamp), parentelement, MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00' GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_12hour.out and title="12 hour increments"
    "SELECT increments(hour, 12, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 00:00:00' AND timestamp <= '2022-02-20 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_day.out and title="1 day increments"
    "SELECT increments(day, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_7day.out and title="7 day increments"
    "SELECT increments(day, 7, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_15day.out and title="15 day increments"
    "SELECT increments(day, 15, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and
    file=!test_dir/altests/increments_functions/test_single_table_increments_month.out and title="1 month increments"
    "SELECT increments(month, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-05-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_1second.out and title="1 second increments"
    "SELECT increments(second, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_30second.out and title="30 second increments"
    "SELECT increments(second, 30, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_1minute.out and title="1 minute increments"
    "SELECT increments(minute, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_30minute.out and title="30 minute increments"
    "SELECT increments(minute, 30, timestamp), device_name, MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00' GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_1hour.out and title="1 hour increments"
    "SELECT increments(hour, 1, timestamp), parentelement, MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00' GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_12hour.out and title="12 hour increments"
    "SELECT increments(hour, 12, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 00:00:00' AND timestamp <= '2022-02-20 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_day.out and title="1 day increments"
    "SELECT increments(day, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_7day.out and title="7 day increments"
    "SELECT increments(day, 7, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_15day.out and title="15 day increments"
    "SELECT increments(day, 15, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and
    file=!test_dir/altests/increments_functions/test_multi_table_increments_month.out and title="1 month increments"
    "SELECT increments(month, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-05-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_1second.out and title="1 second increments"
    "SELECT increments(second, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_30second.out and title="30 second increments"
    "SELECT increments(second, 30, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_1minute.out and title="1 minute increments"
    "SELECT increments(minute, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_30minute.out and title="30 minute increments"
    "SELECT increments(minute, 30, timestamp), device_name, MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00' GROUP BY device_name">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_1hour.out and title="1 hour increments"
    "SELECT increments(hour, 1, timestamp), parentelement, MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 19:00:00' AND timestamp <= '2022-02-15 20:00:00' GROUP BY parentelement">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_12hour.out and title="12 hour increments"
    "SELECT increments(hour, 12, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-15 00:00:00' AND timestamp <= '2022-02-20 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_day.out and title="1 day increments"
    "SELECT increments(day, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_7day.out and title="7 day increments"
    "SELECT increments(day, 7, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_15day.out and title="15 day increments"
    "SELECT increments(day, 15, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-03-01 00:00:00'">

<run client (!conn) sql test format=table and stat=false and test=true and include=(percentagecpu_sensor) and extend=(@table_name as table) and
    file=!test_dir/altests/increments_functions/test_multi_table_extend_increments_month.out and title="1 month increments"
    "SELECT increments(month, 1, timestamp), MIN(timestamp) AS min_ts, MAX(timestamp) AS max_ts, MIN(value) AS min_val, MAX(value) AS max_val, AVG(value)::float(6) AS avg_value, SUM(value)::float(6) AS sum_val, COUNT(*) AS row_count FROM ping_sensor WHERE timestamp >= '2022-02-01 00:00:00' AND timestamp < '2022-05-01 00:00:00'">




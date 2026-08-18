#-----------------------------------------------------------------------------------------------------------------------
# The following file is intended as a placeholder for user implemented code. The file is automatically called by master,
# operator, publisher, query or single_node (operator / publisher) files. If not is written then nothing runs.
#
# Sample commands could include things like;
#   * complicated MQTT calls
#   * Kafka requests
#   * non-standard schedule processes, such as recording disk usage and automated queries
#
# Documentation: https://github.com/AnyLog-co/documentation
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/local_script.al

# Antonio's local script
<run msg client where
broker=127.0.0.1 and 
port=1883 and 
user-agent=anylog and 
log=false and 
topic=(name=antonio/weatherstation/elpaso_001 and dbms=antonio_demo1 and 
table=weather_full and column.timestamp.timestamp="bring [timestamp]" and 
column.station_id=(type=str and value="bring [station_id]") and 
column.wind_speed_ms=(type=float and value="bring [wind][speed_ms]") and 
column.wind_speed_mph=(type=float and value="bring [wind][speed_mph]") and 
column.wind_direction_deg=(type=float and value="bring [wind][direction_deg]") and 
column.wind_direction_cardinal=(type=str and value="bring [wind][direction_cardinal]") and 
column.air_temp_c=(type=float and value="bring [air][temperature_c]") and 
column.air_temp_f=(type=float and value="bring [air][temperature_f]") and 
column.humidity_pct=(type=float and value="bring [air][humidity_pct]") and 
column.pressure_hpa=(type=float and value="bring [pressure][station_hpa]") and 
column.rain_24hr_mm=(type=float and value="bring [rain][accum_24hr_mm]") and 
column.battery_v=(type=float and value="bring [quality][battery_v]"))
>

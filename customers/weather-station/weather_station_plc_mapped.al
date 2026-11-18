#-----------------------------------------------------------------------------------------------------------#
# Weather Station Demo - AnyLog Modbus PLC client with a mapping policy (pairs with weather_station_plc.py)
#
# AnyLog polls each station's PLC directly over Modbus TCP (no MQTT).
#
# Weather: one poll reads 6 registers; the mapping policy's `params` turns that one read into
#          6 rows (one per instrument) in ONE long table, same shape as the MQTT schema + instrument:
#              timestamp | station_id | location | instrument  | unit | value
#              ...       | WS-001     | Fresno.. | temperature | degF | 72.5
#              ...       | WS-001     | Fresno.. | humidity    | pct  | 40.1   ...
#          group_by_attributes = [station_id] -> each station's UNS object gets WHERE station_id = 'WS-00N'
#
# Heartbeat: independent clients (register 106) into their own `heartbeat` table, no policy.
#
# Start the simulator first (port must match !plc_port):
#   python3 weather_station_plc.py --port 5020
#
# Registers: 100 temperature x10 | 101 humidity x10 | 102 pressure x10 | 103 wind_speed x10
#            104 wind_direction x10 | 105 rain x10 | 106 heartbeat (uint16)
#
# list of constants options (device_id = Modbus unit ID; with --separate-ports, port = 5020 + device_id - 1)
#  - device_id = 1  -->  {"station_id": "WS-001", "location": "Fresno, CA"}     (port 5020)
#  - device_id = 2  -->  {"station_id": "WS-002", "location": "Nice, France"}   (port 5021)
#  - device_id = 3  -->  {"station_id": "WS-003", "location": "Seattle, WA"}    (port 5022)
#  - device_id = 4  -->  {"station_id": "WS-004", "location": "Phoenix, AZ"}    (port 5023)
#  - device_id = 5  -->  {"station_id": "WS-005", "location": "Tokyo, Japan"}   (port 5024)
#
# process !local_scripts/weather_station_plc.al
#-----------------------------------------------------------------------------------------------------------#
# process !local_scripts/customers/weather_station_demo/weather_station_plc_mapped.al

on error ignore

set plc_ip = 10.0.0.169          # machine running weather_station_plc.py
set plc_port = 5020             # --port given to weather_station_plc.py
set plc_frequency = 5           # seconds; matches the simulator's --interval
set hb_frequency = 5            # heartbeat poll, can differ from the weather poll
set policy_id = weather-stations-plc
set create_policy = false

#------------------------------------------------- maps ----------------------------------------------------#
<plc_map = [
    {"name": "temperature",    "register": 100, "type": "float", "scale": 0.1},
    {"name": "humidity",       "register": 101, "type": "float", "scale": 0.1},
    {"name": "pressure",       "register": 102, "type": "float", "scale": 0.1},
    {"name": "wind_speed",     "register": 103, "type": "float", "scale": 0.1},
    {"name": "wind_direction", "register": 104, "type": "float", "scale": 0.1},
    {"name": "rain",           "register": 105, "type": "float", "scale": 0.1}
]>

<hb_map = [
    {"name": "heartbeat", "register": 106, "type": "float"}
]>

#--------------------------------------------- mapping policy ----------------------------------------------#

:check-policy:
is_policy = blockchain get mapping where id = !policy_id
if !is_policy then goto test-read
if not !is_policy and !create_policy == true then goto declare-policy-error

:declare-policy:
# params: one row per entry -> [instrument (literal), unit (literal), value (bring from the PLC read)]
<new_policy = {"mapping": {
    "id": !policy_id,
    "dbms": !default_dbms,
        "table": "weather_stations",
    "group_by_attributes": ["station_id"],
    "readings": "",
    "params": [
        ["temperature",    "degF", "[temperature]"],
        ["humidity",       "pct",  "[humidity]"],
        ["pressure",       "hPa",  "[pressure]"],
        ["wind_speed",     "m/s",  "[wind_speed]"],
        ["wind_direction", "deg",  "[wind_direction]"],
        ["rain",           "mm",   "[rain]"]
    ],
    "schema": {
        "timestamp":  {"type": "timestamp", "default": "now()", "bring": "[timestamp]"},
        "station_id": {"type": "str",   "default": null, "bring": "[station_id]"},
        "location":   {"type": "str",   "default": null, "bring": "[location]"},
        "instrument": {"type": "str",   "default": "params.0"},
        "unit":       {"type": "str",   "default": "params.1"},
        "value":      {"type": "float", "default": null, "bring": "params.2"}
    }
}}>

:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

:test-read:

<get plc values where type = modbus and
    hostname = !plc_ip and port = !plc_port and device_id = 1 and
    map = !plc_map
>

<run plc client where type = modbus and
    name = ws_001 and hostname = !plc_ip and port = !plc_port and device_id = 1 and frequency = !plc_frequency and
    policy = !policy_id and auto_uns = true and master_node = !ledger_conn and dbms=!default_dbms and
    constants = {"station_id": "WS-001", "location": "Fresno, CA"} and
    table_per_value=false and table=weather_stations and map = !plc_map
>
:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts

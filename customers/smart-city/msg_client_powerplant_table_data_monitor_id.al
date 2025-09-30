#----------------------------------------------------------------------------------------------------------------------#
# The following provides pulling the Smart City power-plant data and then storing it in tables based on monitor_id
# :sample data:
# {
#    "monitor_id":"BSP",
#    "timestamp":"2025-09-24T17:39:19.4393010Z",
#    "A_Current":1,
#    "A_N_Voltage":730,
#    "B_Current":1,
#    "B_N_Voltage":735,
#    "C_Current":1,
#    "C_N_Voltage":732,
#    "CommsStatus":"true",
#    "EnergyMultiplier":1,
#    "Frequency":5998,
#    "PowerFactor":100,
#    "ReactivePower":1,
#    "RealPower":17
# }
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/customers/smart-city/msg_client_data_monitor_id.al


on error ignore

if not !default_dbms then default_dbms=cos
<run msg client where
    broker=172.104.228.251 and port=1883 and
    user=anyloguser and password=mqtt4AnyLog! and
    log=false and
    topic=(
        name=power-plant and
        dbms=!default_dbms and
        table="bring [monitor_id]" and
        column.timestamp.timestamp="bring [timestamp]" and
        column.a_current.float="bring [A_Current]" and
        column.a_n_voltage.float="bring [A_N_Voltage]" and
        column.b_current.float="bring [B_Current]" and
        column.b_n_voltage.float="bring [B_N_Voltage]" and
        column.c_current.float="bring [C_Current]" and
        column.c_n_voltage.float="bring [C_N_Voltage]" and
        column.comms_status.bool="bring [CommsStatus]" and
        column.energy_multiplier.int="bring [EnergyMultiplier]" and
        column.frequency.float="bring [Frequency]" and
        column.power_factor.int="bring [PowerFactor]" and
        column.reactive_power.int="bring [ReactivePower]" and
        column.real_power.float="bring [ReactivePower]"
    )>
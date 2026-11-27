<run msg client  where broker=172.104.228.251 and  port=1883 and user=anyloguser and password=mqtt4AnyLog! and log=false and topic=(
    name="power-plant" and
    dbms=nov and
    table="pp_pm" and
    column.timestamp.timestamp="bring [timestamp]" and
    column.monitor_id=(type=str and value="bring [monitor_id]") and
    column.commsstatus=(type=bool and value="bring [CommsStatus]" and optional=true) and
    column.pv=(type=float and value="bring [PV]" and optional=true) and
    column.realpower=(type=float and value="bring [RealPower]" and optional=true) and
    column.reactivepower=(type=float and value="bring [ReactivePower]" and optional=true) and
    column.a_current=(type=float and value="bring [A_Current]" and optional=true) and
    column.a_n_voltage=(type=float and value="bring [A_N_Voltage]" and optional=true) and
    column.b_current=(type=float and value="bring [B_Current]" and optional=true) and
    column.b_n_voltage=(type=float and value="bring [B_N_Voltage]" and optional=true) and
    column.c_current=(type=float and value="bring [C_Current]" and optional=true) and
    column.c_n_voltage=(type=float and value="bring [C_N_Voltage]" and optional=true) and
    column.energymultiplier=(type=float and value="bring [EnergyMultiplier]" and optional=true) and
    column.frequency=(type=float and value="bring [Frequency]" and optional=true) and
    column.powerfactor=(type=float and value="bring [PowerFactor]" and optional=true))>
    



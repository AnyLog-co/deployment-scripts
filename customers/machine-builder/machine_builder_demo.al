#----------------------------------------------------------------------------------------------------------------------#
# Machine builder demo
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_root/deployment-scripts/machine-builder/machine_builder_demo.al

on error ignore
:set-database:

on error goto orics-dbms-error
if !db_type == psql then
<do connect dbms orics where
    type=!db_type and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port and
    autocommit = !autocommit and
    unlog = !unlog
>
else connect dbms orics where type=!db_type

:data-partitioning:
if !enable_partitions == true then
do partition orics * using timestamp by !partition_interval
<do schedule time=!partition_sync and name="Drop Orics Partitions"
    task drop partition where dbms=orics and table =* and keep=3>

:run-mqtt-client:
on error goto run-mqtt-client-error
<run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
   name="Orics/R-50" and
   dbms=orics and
   table=r_50 and
   column.timestamp.timestamp="bring [ts]" and
   column.serial_number.str="bring [serial_number]" and
   column.seal_storage.float="bring [d][SealStage][0]" and
   column.cy_min.float="bring [d][Cyc/Min][0]" and
   column.batch_count.float="bring [d][BatchCount][0]" and
   column.run_hours.float="bring [d][RunHours][0]" and
   column.machine_state.float="bring [d][MachineState][0]" and
   column.denester_in_cycle=(type=str and value="bring [d][DenesterInCycle][0]") and
   column.filler_stage.float="bring [d][FillerStage][0]" and
   column.filler_cyc_time.float="bring [d][FillerCycTime][0]" and
   column.seal_cyc_time.float="bring [d][SealCycTime][0]" and
   column.heater1_setpoint.float="bring [d][Heater1Setpoint][0]" and
   column.heater1_temp.float="bring [d][Heater1Temp][0]" and
   column.cap_pick_in_cyc=(type=str and value="bring [d][CapPickInCyc][0]") and
   column.cap_press_in_cyc=(type=str and value="bring [d][CapPressInCyc][0]") and
   column.rotary_index_rdy=(type=str and value="bring [d][RotaryIndexRDY][0]") and
   column.rotary_index_run=(type=str and value="bring [d][RotaryIndexRun][0]") and
   column.rotary_index_i.float="bring [d][RotaryIndexI][0]" and
   column.outfeed_conv_rdy=(type=str and value="bring [d][OutfeedConvRDY][0]") and
   column.outfeed_conv_run=(type=str and value="bring [d][OutfeedConvRun][0]") and
   column.outfeed_conv_i.float="bring [d][OutfeedConvI][0]" and
   column.film_supply_rdy=(type=str and value="bring [d][FilmSupplyRDY][0]") and
   column.film_supply_run=(type=str and value="bring [d][FilmSupplyRun][0]") and
   column.film_supply_i.float="bring [d][FilmSupplyI][0]" and
   column.film_adv_rdy=(type=str and value="bring [d][FilmAdvRDY][0]") and
   column.film_adv_run=(type=str and value="bring [d][FilmAdvRun][0]") and
   column.film_adv_i.float="bring [d][FilmAdvI][0]"  and
   column.airpressureok=(type=str and value="bring [d][AirPressureOk][0]")
)>

:end-script:
end script

:terminate-scripts:
exit scripts

:orics-dbms-error:
echo "Error: Unable to connect to orics database with db type: " !db_type ". Cannot continue"
goto terminate-scripts

:run-mqtt-client-error:
echo "Error: Failed to start (REST) mqtt client"
goto terminate-scripts


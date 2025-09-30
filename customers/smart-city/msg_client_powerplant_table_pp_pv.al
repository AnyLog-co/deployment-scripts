#----------------------------------------------------------------------------------------------------------------------#
# The following provides pulling the Smart City power-plant data and then storing it in table called pp_pv
# :sample data:
# {
#    "monitor_id":"InconLoadTapChangerAI",
#    "timestamp":"2025-09-24T18:29:31.7330362Z",
#    "PV":1.9200000762939453
# }
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/customers/smart-city/msg_client_data_pp_pm.al


on error ignore

if not !default_dbms then default_dbms=cos
<run msg client where
    broker=172.104.228.251 and port=1883 and
    user=anyloguser and password=mqtt4AnyLog! and
    log=false and topic=(
        name=power-plant-pv and
        dbms=!default_dbms and
        table=pp_pv and
        column.timestamp.timestamp="bring [timestamp]" and
        column.pv.float="bring [PV]"
    )>
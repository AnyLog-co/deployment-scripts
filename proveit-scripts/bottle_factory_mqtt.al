#--------------------------------------------------------#
# Bottle Factory Msg Client                              #
#--------------------------------------------------------#
on error ignore
:kpi-client:
#--------------------------------------------------------#
# :Sample Data:
# {
#   "dbms":"bottle_factory",
#   "timestamp":"2026-01-23T02:14:19Z",
#   "site":"Site1",
#   "asset":"sealer",
#   "quality":1,
#   "performance":1.03272293814433,
#   "oee":0.7204180151024812,
#   "availability":0.6975907946781733,
#   "table":"kpi"
# }
#--------------------------------------------------------#
reset error log

<run msg client where
	broker = !mqtt_broker and port=!mqtt_port and
	user = !mqtt_user and password = !mqtt_passwd and
	master_node = !ledger_conn and
	log = false and topic = (
		name=!mqtt_topic and
		dbms=!default_dbms and
		dynamic = True
	)>

wait 120
run uns streamer

:end-script:
end script
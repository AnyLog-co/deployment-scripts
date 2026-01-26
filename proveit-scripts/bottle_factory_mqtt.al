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
BROKER = "virtualfactory.proveit.services"
PORT = 1883
USERNAME = "proveitreadonly"
PASSWORD = "proveitreadonlypassword"
# default_dbms = my_dbms

<run msg client where
	broker = !BROKER and port=!PORT and
	user = !USERNAME and password = !PASSWORD and
	master_node = !ledger_conn and
	log = false and topic = (
		name="Enterprise B/Site1/#" and
		dbms=proveit and
		dynamic = True
	)>

wait 120
run uns streamer


# :processing-client:
# <run msg client where broker=local and log=false and topic=(
#   name=processing and
#   dbms=!default_dbms and
#   table="bring [table]" and
#   column.timestamp.timestamp = "bring [timestamp]" and
#   column.site.str = "bring [site]" and
#   column.tank.str = "bring [tank]" and
#   column.lot_id.str = "bring [lotnumberid]" and
#   column.state.str = "bring [state]" and
#   column.duration.float = "bring [duration]" and
#   column.flowrate.float = "bring [flowrate]" and
#   column.temperature.float = "bring [temperature]" and
#   column.weight.float = "bring [weight]"
#)>

:end-script:
end script
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
<run msg client where broker=local and log=false and topic=(
   name=kpi and
   dbms=!default_dbms and
   table="bring [table]" and
   column.timestamp.timestamp = "bring [timestamp]" and
   column.site.str = "bring [site]" and
   column.asset.str = "bring [asset]" and
   column.lot_id.str = "bring [lotnumberid]" and
   column.oee.float = "bring [oee]" and
   column.performance.float = "bring [performance]" and
   column.quality.float = "bring [quality]" and
   column.availability.float = "bring [availability]"
)>

:processing-client:
<run msg client where broker=local and log=false and topic=(
   name=processing and
   dbms=!default_dbms and
   table="bring [table]" and
   column.timestamp.timestamp = "bring [timestamp]" and
   column.site.str = "bring [site]" and
   column.tank.str = "bring [tank]" and
   column.lot_id.str = "bring [lotnumberid]" and
   column.state.str = "bring [state]" and
   column.duration.float = "bring [duration]" and
   column.flowrate.float = "bring [flowrate]" and
   column.temperature.float = "bring [temperature]" and
   column.weight.float = "bring [weight]"
)>

:end-script:
end script
#--------------------------------------------------------#
# Manufacturing Historian Msg Client                     #
#--------------------------------------------------------#
on error ignore
:msg-client:
<run msg client where broker = !mqtt_broker and port=!PORT and user = !mqtt_user and password = !mqtt_passwd and
                      log = false and topic = (
                        name=!mqtt_topic and
                        dbms=!default_dbms and
                        table="bring [table]" and
                        column.timestamp.timestamp = "bring [timestamp]" and
                        column.value.str="bring [value]"
)>
:end-script:
end script
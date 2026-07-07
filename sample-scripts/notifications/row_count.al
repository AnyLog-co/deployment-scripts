#----------------------------------------------------------------------------------------------------------------------#
# Notifications regarding table/data availability run via the Query node, since it requires `system_query`
# request, scanning all relevant operator node(s).
#
# Unlike the per-table variant of this script, this version does NOT require the user to manually define
# alert_dbms / alert_table per copy. Instead, it pulls the full list of tables currently registered on the
# blockchain (`blockchain get table`) and loops over every dbms/table pair, checking whether each table has
# received any rows in the last 5 minutes. This is meant as a general "is data still flowing" health check
# across the network, rather than a check on a specific column/value per table.
#
# Message (msg_*) configs are still defined once per script rather than centrally, since different scripts /
# deployments may need to route "no data" alerts to different chats or notification services. Query configs
# (alert_dbms, alert_table, expected_value) are left in :set-params: for consistency with the per-table
# variant of this script, but are overwritten each loop iteration from the blockchain table list and are not
# used to filter which tables get checked in this version.
#
#:notes:
#   - "no data" is currently only printed (see :analyze-data: equivalent loop below), not sent as a notification;
#     :send-msg: is defined but never called from the table-scan loop.
#   - adjust the 5-minute / row-count=0 threshold below if a different staleness window is needed.
#
# Because AnyLog variables are shared across scripts running on the same node, every deployed copy of a notification
# script needs its own variable namespace (e.g. a prefix unique to that instance: rowcount_msg_url, wwp_msg_url,
# torque_msg_url, etc.) for all set-params variables — not just the message config, but the query config too
# (alert_dbms, alert_table) if multiple copies run concurrently. A generic name like msg_type is fine only if you're
# certain no other active script on the node reuses it.
#
#:steps:
#   1. review/adjust the staleness window (insert_timestamp >= NOW() - 5 minutes) and row-count threshold
#   2. configure msg_type / msg_url / chat_id / msg_token / msg_user for the desired notification target
#   3. run as a scheduled process
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/notifications/row_count.al
# schedule name = row-count and time = 15 minutes and task process !local_scripts/sample-scripts/notifications/row_count.al

on error ignore

:set-params:
# logical database or database and table combinations to check rather than all tables on the blockchain
alert_dbms = ""
alert_table = ""

# publish msg configs
# which notification backend to use: "telegram" or "pushover"
msg_type = ""

# REST endpoint for the notification service (Telegram/Pushover API URL)
msg_url = ""
# Telegram chat ID to send the alert message to (telegram only)
chat_id = ""
# Pushover application token (pushover only)
msg_token = ""
# Pushover user key (pushover only)
msg_user = ""

if not !alert_dbms then tables = blockchain get table bring.json [*][dbms] [*][name]
else if !alert_dbms and !alert_table then tables = blockchain get table where dbms=!alert_dbms and name=!alert_table bring.json [*][dbms] [*][name]
else if !alert_dbms then tables = blockchain get table where dbms=!alert_dbms bring.json [*][dbms] [*][name]
else goto query-err

for loop start where list = !tables
    query_alert_dbms = from !tables[+] bring [dbms]
    query_alert_table = from !tables[+] bring [name]
    query_result = run client () sql !query_alert_dbms format=json:list and stat=false select count(*) from !query_alert_table where insert_timestamp >= NOW() - 5 minutes

    wait 30 for !query_result        # Wait up to 30 seconds

    for loop start where list = !query_result
        value = json !query_result[+] values
        if !value then act_value = !value[0]
        if not !act_value or !act_value.int <= 0 then
        do message = "Table " + !query_alert_dbms + "." + !query_alert_table + " has no data"
        do call send-msg
    for loop end
for loop end


goto end-script

:send-msg:
if !msg_type == telegram then
do on error goto telegram-err
do telegram_body = json {"chat_id": !chat_id, "text": !message}
do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !telegram_body

else if !msg_type == pushover then
else do on error goto pushover-err
else do pushover_body = json  {"token": !msg_token, "user": !msg_user, "message": !message}
else do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !pushover_body

else goto missing-type

return

:end-script:
end script

:terminate-scripts:
exit scripts

:query-err:
echo "Failed to get results for query"
goto terminate-scripts

:analyze-err:
echo "Failed to extract results from query"
goto terminate-scripts

:telegram-err:
echo "Error: Failed to send Telegram alert: !message"
goto terminate-scripts

:pushover-err:
echo "Error: Failed to send Pushover alert: !message"
goto terminate-scripts

:missing-type:
echo "Error: Invalid message type: " !msg_type
goto terminate-scripts


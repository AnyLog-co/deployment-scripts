#----------------------------------------------------------------------------------------------------------------------#
# Notifications regarding insight from the actual data tend to run via the Query node as it requires `system_query`
# request, scanning all relevant operator node(s).
#
# As such, it is recommended that the user **manually** defines configurations per table / notification system.
# the following example is "specifically" for smart city water (wp_digital) and waste water (wwp_digital) to check if
# the value changed from False -> True.
#
# Query configs and message configs are both defined per-script rather than in a shared/central config. This is because
# scripts run per-table (and thus potentially per database) via the Query node, and different (database and) tables may
# need to notify different destinations (e.g. a different chat_id, msg_url, or msg_type). Keeping both sets of params
# together in one script  per table keeps the query-to-notification mapping explicit and avoids needing conditional
# routing logic in a shared config.
#
#:steps:
#   1. copy existing script per table
#   2. update params
#   3. run as a scheduled process
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/smart-city/wp_digital_notification.al
# schedule name = [service name] and time = 15 minutes and task process !local_scripts/smart-city/wp_digital_notification.al

on error ignore

:set-params:
# query configs
# target database (dbms) name to query, e.g. wp_digital or wwp_digital
alert_dbms = !default_dbms
# target table name within alert_dbms to check for sensor state
alert_table = wp_digital
# value that triggers an alert when a column's value matches this (e.g. "true")
expected_value = false
# specify a column you want to use query
query_column = ""

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

:query-data:
on error goto query-err
set query_result = ""

if !query_column then query_result = run client () sql !alert_dbms format=json:list and stat=false select !query_column from !alert_table where period(hour, 1, now(), timestamp) order by timestamp desc limit 1
else query_result = run client () sql !alert_dbms format=json:list and stat=false select * from !alert_table where period(hour, 1, now(), timestamp) order by timestamp desc limit 1

wait 30 for !query_result        # Wait up to 30 seconds

:analyze-data:

if not !query_result then print "results not found"
on error goto analyze-err

for loop start where list = !query_result
    keys = json !query_result[+] keys
    for loop start where list = !keys
        act_value = ""
        key = !keys[+]
        if !key != row_id and !key != insert_timestamp and !key != tsd_name and !key != tsd_id and !key != timestamp then
        do act_value = from !query_result[+] bring [!key]
        if !act_value != "" and !act_value != !expected_value then
        do message = "Ori - Water plant ALERT name=" + !key + " value=" + !act_value
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
else do pushover_body = {"token": !msg_token, "user": !msg_user, "message": !message}
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


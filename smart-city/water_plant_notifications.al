#----------------------------------------------------------------------------------------------------------------------#
# Pushover for Customer using Pushover for Water Plant
# :scheduler command:
#   <schedule
#       time = "15 minute" and
#       name = water-alerts and
#       task process !local_scripts/smart-city/water_plant_notifications.al
#----------------------------------------------------------------------------------------------------------------------#

:set-params:

alert_dbms = cos
alert_table = wp_digital
expected_value = false
query_column = ""

# publish msg configs
# which notification backend to use: "telegram" or "pushover"
msg_type = ""

# REST endpoint for the notification service (Telegram/Pushover API URL)
msg_url = "https://api.pushover.net/1/messages.json"
# Telegram chat ID to send the alert message to (telegram only)
chat_id = ""
# Pushover application token (pushover only)
msg_token = "a2ifbydwwvz4g8xh6qv5qkquc324ju"
# Pushover user key (pushover only)
msg_user = "uc4cwexgst196sdmz8n9tqyevhuj9h"


:query-data:
on error goto query-err
query_columns =
set query_result = ""


<query_result = run client () sql !alert_dbms format=json:list and stat=false
    "SELECT
        timestamp, clearwellhighleveldi, clearwelllowleveldi, combinedchlorinatorvacdi, freechlorinatorvacdi,
        generatoralarmdi, oxygenmonitordi, watertowerlevelcommsdi
    FROM
        !alert_table
    WHERE
        period(hour, 1, now(), timestamp)
    ORDER BY timestamp DESC
    LIMIT 1">

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
        do message = "Water plant ALERT name=" + !key + " value=" + !act_value
        do call send-msg
    for loop end
for loop end


:send-message:
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


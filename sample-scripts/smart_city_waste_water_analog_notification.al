#----------------------------------------------------------------------------------------------------------------------#
# Monitors smart-city waste water plant analog data and alerts when no rows are received within the expected time window.
# Queries a row count against the alert table for the given time window; if count is zero, sends a stale-data alert.
#
# Environment variables:
#   ALERT_DB        - logical database to query (default: !default_dbms)
#   ALERT_TABLE     - table to query (default: wp_analog)
#   STABLE_MINUTES  - how far back to look for recent data (default: 30 minutes)
#   MSG_TYPE        - notification channel: telegram or pushover
#   MSG_URL         - endpoint URL for the selected channel
#   CHAT_ID         - Telegram chat ID (required if MSG_TYPE=telegram)
#   MSG_TOKEN       - Pushover app token (required if MSG_TYPE=pushover)
#   MSG_USER        - Pushover user key (required if MSG_TYPE=pushover)
#
# Data generator:
#   process !local_scripts/data-generator/smart_city_waste_water_plant.al
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/smart_city_waste_water_analog_notification.al

on error ignore

:set-params:
# logical database + table to gather insight from
if $ALERT_DB then alert_db = $ALERT_DB
if $ALERT_TABLE then alert_table = $ALERT_TABLE
else alert_table = wwp_analog

# expected delay time
stale_minutes = 30 minutes
if $STABLE_MINUTES then stale_minutes = $STABLE_MINUTES

if $MSG_TYPE then msg_type = $MSG_TYPE
if $MSG_URL then msg_url = $MSG_URL
if $CHAT_ID then chat_id = $CHAT_ID
if $MSG_TOKEN then msg_token = $MSG_TOKEN
if $MSG_USER then msg_user = $MSG_USER

goto validate-configs

:get-data:
on error goto query-err
if !alert_db then stale_q = run client () sql !alert_db format=json:list and stat=false "select count(*) as row_count from !alert_table where timestamp >= NOW() - !stale_minutes"
else stale_q = run client () sql !default_dbms format=json:list and stat=false "select count(*) as row_count from !alert_table where timestamp >= NOW() - !stale_minutes"

wait 35 for !stale_q

# if data not returned send a push notification & end script
if !stale_q then stale_q = from !stale_q bring [ro
if not !stale_q or !stale_q.int <= 0 then
do message = "Warning: No data returned on !alert_table - script will stop"
do call send-msg
do goto end-script

:send-msg:
if !msg_type == telegram then
do on error goto telegram-err
do telegram_body = {"chat_id": !chat_id, "text": !message}
do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !telegram_body

else if !msg_type == pushover then
do on error goto pushover-err
do pushover_body = {"token": !msg_token, "user": !msg_user, "message": !message}
do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !pushover_body

:end-script:
end script

:validate-configs:
err_code = 0

# connection info to push data notification
if $MSG_TYPE and $MSG_TYPE != pushover and $MSG_TYPE != telegram then
do echo "Error: invalid notification push type pushover or telegram. Unable to continue..."
do err_code = 1

if not !msg_url then
do echo "Error: Missing msg_url - cannot continue"
do err_code = 1

if !msg_type == telegram and not !chat_id then
do echo "Error: Missing chat_id for Telegram - cannot continue"
do err_code = 1

if !msg_type == pushover and not !msg_token or not !msg_user then
do echo "Error: Missing token or user for Pushover - cannot continue"
do err_code = 1

if err_code == 1 then goto end-script

goto get-data


:query-err:
echo "Error: Failed to execute query"
goto end-script

:telegram-err:
echo "Error: Failed to send Telegram alert: !message"
goto end-script

:pushover-err:
echo "Error: Failed to send Pushover alert: !message"
goto end-script

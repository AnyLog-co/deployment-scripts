#----------------------------------------------------------------------------------------------------------------------#
# Monitors smart-city water plant analog data and alerts when no rows are received within the expected time window.
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
#   process !local_scripts/smart-city/power_plant.al
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/smart-city/power_plant_pv_notification.al

on error ignore

:set-params:
# specify all unique params here prior to `process command`
alert_table = pv

process !local_scripts/smart-city/notification_params.al

if !alert_db then selected_db = !alert_db
else selected_db = !default_dbms

:get-data:
on error goto query-err
stale_q = run client () sql !selected_db format=json:list and stat=false "select count(*) as row_count from !alert_table where timestamp >= NOW() - !stale_minutes"

wait 35 for !stale_q

# if data not returned send a push notification & end script
if !stale_q then stale_q = from !stale_q bring [row_count]
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

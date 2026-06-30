#----------------------------------------------------------------------------------------------------------------------#
# Set params for notifications if not specified
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
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/smart-city/notification_params.al

:set-params:
# logical database + table to gather insight from
if $ALERT_DB and not !alert_db then alert_db = $ALERT_DB

# expected delay time
if $STABLE_MINUTES and not !stale_minutes then stale_minutes = $STABLE_MINUTES

if $MSG_TYPE  and not !msg_type then msg_type = $MSG_TYPE
if $MSG_URL   and not !msg_url then msg_url = $MSG_URL
if $CHAT_ID   and not !chat_id then chat_id = $CHAT_ID
if $MSG_TOKEN and not !msg_token then msg_token = $MSG_TOKEN
if $MSG_USER  and not !msg_user then msg_user = $MSG_USER

goto validate-configs

:end-script:
end script

:terminate-scripts:
exit scripts

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

if err_code == 1 then goto terminate-scripts

goto end-script

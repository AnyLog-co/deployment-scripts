#----------------------------------------------------------------------------------------------------------------------#
# Monitors smart-city water plant digital sensor fields and sends alerts when a value deviates from the expected state.
# Queries the most recent row from the alert table and checks each boolean field against expect_value (default: false).
# If a field deviates, an alert is sent via Telegram or Pushover before continuing to the next field.
#
# Environment variables:
#   ALERT_DB        - logical database to query (default: !default_dbms)
#   ALERT_TABLE     - table to query (default: wp_digital)
#   STABLE_MINUTES  - how far back to look for recent data (default: 5 minutes)
#   EXPECT_VALUE    - value fields are expected to hold (default: false)
#   MSG_TYPE        - notification channel: telegram or pushover
#   MSG_URL         - endpoint URL for the selected channel
#   CHAT_ID         - Telegram chat ID (required if MSG_TYPE=telegram)
#   MSG_TOKEN       - Pushover app token (required if MSG_TYPE=pushover)
#   MSG_USER        - Pushover user key (required if MSG_TYPE=pushover)
#
# Data generator:
#   process !local_scripts/data-generator/smart_city_water_plant.al
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/smart_city_water_notification.al

on error ignore

:set-params:
# logical database + table to gather insight from
if $ALERT_DB then alert_db = $ALERT_DB
if $ALERT_TABLE then alert_table = $ALERT_TABLE
else alert_table = wp_digital

# expected delay time
stale_minutes = 5 minutes
if $STABLE_MINUTES then stale_minutes = $STABLE_MINUTES


# expected value
expect_value = false
if $EXPECT_VALUE then set expect_value = $EXPECT_VALUE

if $MSG_TYPE then msg_type = $MSG_TYPE
if $MSG_URL then msg_url = $MSG_URL
if $CHAT_ID then chat_id = $CHAT_ID
if $MSG_TOKEN then msg_token = $MSG_TOKEN
if $MSG_USER then msg_user = $MSG_USER

sent_count = 0

goto validate-configs

:get-data:
on error goto query-err
if !alert_db then stale_q = run client () sql !alert_db format=json:list and stat=false "select * from !alert_table where timestamp >= NOW() - !stale_minutes ORDER BY timestamp DESC LIMIT 1"
else stale_q = run client () sql !default_dbms format=json:list and stat=false "select * from !alert_table where timestamp >= NOW() - !stale_minutes ORDER BY timestamp DESC LIMIT 1"

wait 35 for !stale_q

# if data not returned send a push notification & end script
if not !stale_q then
do message = "Warning: No data returned on !alert_table - script will stop"
do call send-msg
do goto end-script


:check-data:
on error goto check-err

cur_v = from !stale_q bring ['atsnormalrdydi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=atsnormalrdydi value=!cur_v"
do call send-msg

:check-atsonstandby:
cur_v = from !stale_q bring ['atsonstandbydi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=atsonstandbydi value=!cur_v"
do call send-msg

:check-atsstandbyrdydi:
cur_v = from !stale_q bring ['atsstandybyrdydi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=atsstandybyrdydi value=!cur_v"
do call send-msg

:check-clearwellhigh:
cur_v = from !stale_q bring ['clearwellhighleveldi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=clearwellhighleveldi value=!cur_v"
do call send-msg

:check-clearwelllow:
cur_v = from !stale_q bring ['clearwelllowleveldi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=clearwelllowleveldi value=!cur_v"
do call send-msg

:check-generatoralarm:
cur_v = from !stale_q bring ['generatoralarmdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=generatoralarmdi value=!cur_v"
do call send-msg

:check-generatorstatus:
cur_v = from !stale_q bring ['generatorstatusdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=generatorstatusdi value=!cur_v"
do call send-msg

:check-oxygenmonitor:
cur_v = from !stale_q bring ['oxygenmonitordi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=oxygenmonitordi value=!cur_v"
do call send-msg

:check-plantrunning:
cur_v = from !stale_q bring ['plantrunningdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantrunningdi value=!cur_v"
do call send-msg

:check-plantstart:
cur_v = from !stale_q bring ['plantstartdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantstartdi value=!cur_v"
do call send-msg

:check-servicepump1:
cur_v = from !stale_q bring ['servicepump1running_di']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=servicepump1running_di value=!cur_v"
do call send-msg

:check-servicepump2:
cur_v = from !stale_q bring ['servicepump2running_di']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=servicepump2running_di value=!cur_v"
do call send-msg

:check-plantshutdown:
cur_v = from !stale_q bring ['plantshutdowndo']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantshutdowndo value=!cur_v"
do call send-msg

:check-watertower:
cur_v = from !stale_q bring ['watertowerlevelcommsdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=watertowerlevelcommsdi value=!cur_v"
do call send-msg

:check-chemicals:
cur_v = from !stale_q bring ['plantenablechemicalsdo']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantenablechemicalsdo value=!cur_v"
do call send-msg

:check-combinedchlorinator:
cur_v = from !stale_q bring ['combinedchlorinatorvacdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=combinedchlorinatorvacdi value=!cur_v"
do call send-msg

:check-freechlorinator:
cur_v = from !stale_q bring ['freechlorinatorvacdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=freechlorinatorvacdi value=!cur_v"
do call send-msg

:check-carbonfeeder:
cur_v = from !stale_q bring ['carbonfeeder_runningfwd']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=carbonfeeder_runningfwd value=!cur_v"
do call send-msg

goto end-script


:send-msg:
if !msg_type == telegram then
do on error goto telegram-err
do telegram_body = {"chat_id": !chat_id, "text": !message}
do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !telegram_body

else if !msg_type == pushover then
do on error goto pushover-err
do pushover_body = {"token": !msg_token, "user": !msg_user, "message": !message}
do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !pushover_body

sent_count = python sent_count.int + 1
return

:end-script:
end script

:validate-configs:
err_code = 0

# connection info to push data notification
if $MSG_TYPE and $MSG_TYPE != pushover and $MSG_TYPE != telegram then
do echo "Error: invalid notification push type pushover or telegram. Unable to continue..."
do err_code = 1

if not !expect_value then
do echo "Error: Missing calculation info - cannot continue"
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

:check-err:
echo "Error: Failed to extract insight"
goto end-script

:telegram-err:
echo "Error: Failed to send Telegram alert: !message"
goto end-script

:pushover-err:
echo "Error: Failed to send Pushover alert: !message"
goto end-script

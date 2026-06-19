#----------------------------------------------------------------------------------------------------------------------#
# Monitors smart-city water plant digital sensor fields and sends alerts when a value deviates from the expected state.
# Queries the most recent row from the alert table and checks each boolean field against expect_value (default: false).
# If a field deviates, an alert is sent via Telegram or Pushover before continuing to the next field.

echo off
set echo queue off

# Smart city drinking water notification — env-driven alert script
#
# Deploy: /app/deployment-scripts/smart_city_water_notification.al
# process !scripts_dir/smart_city_water_notification.al
#
# Environment variables (optional unless noted):
#   ALERT_DB      — logical dbms (if unset, uses !default_dbms)
#   ALERT_TABLE   — table name (default: wp_digital)
#   STALE_MINUTES — minutes without data = stale (default: 5)
#   EXPECT_VALUE  — alert when flag != this (default: false)
#   MSG_TYPE      — telegram or pushover (required)
#   MSG_URL       — notification API URL (required)
#   CHAT_ID       — Telegram chat id (required for telegram)
#   MSG_TOKEN     — Pushover app token (required for pushover)
#   MSG_USER      — Pushover user key (required for pushover)

on error ignore

:set-params:
# logical database + table to gather data from
if $ALERT_DB then alert_db = $ALERT_DB
if $ALERT_TABLE then alert_table = $ALERT_TABLE
else alert_table = wp_digital

# expected delay time
stale_minutes = 5
if $STALE_MINUTES then stale_minutes = $STALE_MINUTES

# expected value
expect_value = false
if $EXPECT_VALUE then expect_value = $EXPECT_VALUE

if $MSG_TYPE then msg_type = $MSG_TYPE
if $MSG_URL then msg_url = $MSG_URL
if $CHAT_ID then chat_id = $CHAT_ID
if $MSG_TOKEN then msg_token = $MSG_TOKEN
if $MSG_USER then msg_user = $MSG_USER

# Console debug message
print Water plant ALERT starts

sent_count = 0
goto validate-configs

:get-data:
on error goto query-err

if !alert_db then selected_db = !alert_db
else selected_db = !default_dbms

stale_q = run client () sql !selected_db format=json:list and stat=false "select * from wp_digital where timestamp >= NOW() - !stale_minutes minutes order by timestamp desc limit 1"

wait 35 for !stale_q

# Console data dump
get !stale_q

# No rows in stale window — notify and stop
if !stale_q == "" or !stale_q contains "Empty data set" then
do print Warning: No data returned on !alert_table
do message = "Warning: No data returned on " + !alert_table + " in " + !stale_minutes + " minutes - script will stop"
do call send-msg
do goto end-script

:check-data:
on error goto check-err

cur_v = from !stale_q(0) bring ['atsnormalrdydi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=atsnormalrdydi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['atsonstandbydi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=atsonstandbydi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['atsstandybyrdydi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=atsstandybyrdydi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['clearwellhighleveldi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=clearwellhighleveldi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['clearwelllowleveldi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=clearwelllowleveldi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['generatoralarmdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=generatoralarmdi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['generatorstatusdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=generatorstatusdi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['oxygenmonitordi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=oxygenmonitordi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['plantrunningdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantrunningdi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['plantstartdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantstartdi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['servicepump1running_di']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=servicepump1running_di value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['servicepump2running_di']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=servicepump2running_di value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['plantshutdowndo']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantshutdowndo value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['watertowerlevelcommsdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=watertowerlevelcommsdi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['plantenablechemicalsdo']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=plantenablechemicalsdo value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['combinedchlorinatorvacdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=combinedchlorinatorvacdi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['freechlorinatorvacdi']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=freechlorinatorvacdi value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['carbonfeeder_runningfwd']
if !cur_v != !expect_value then
do message = "Water plant ALERT name=carbonfeeder_runningfwd value=" + !cur_v
do call send-msg

print Water plant ALERT completed sent=!sent_count
goto end-script

:send-msg:
if !msg_type == "telegram" then
do on error goto telegram-err
do telegram_body = json {"chat_id":!chat_id,"text":!message}
do print CALLED telegram !msg_url !chat_id !telegram_body
do rest post where url = !msg_url and headers = {"Content-Type":"application/json"} and body = !telegram_body
do sent_count = incr !sent_count
return

if !msg_type == "pushover" then
do on error goto pushover-err
do pushover_body = json {"token":!msg_token,"user":!msg_user,"message":!message}
do print CALLED pushover !msg_url !msg_user !pushover_body
do rest post where url = !msg_url and headers = {"Content-Type":"application/json"} and body = !pushover_body
do sent_count = incr !sent_count
return

print Unknown msg_type=!msg_type
return

:end-script:
end script

:validate-configs:
err_code = 0

if $MSG_TYPE and $MSG_TYPE != "pushover" and $MSG_TYPE != "telegram" then
do echo Error: invalid notification type - use pushover or telegram
do err_code = 1

if not !msg_url then
do echo Error: Missing msg_url - cannot continue
do err_code = 1

if !msg_type == "telegram" and not !chat_id then
do echo Error: Missing chat_id for Telegram - cannot continue
do err_code = 1

if !msg_type == "pushover" and (not !msg_token or not !msg_user) then
do echo Error: Missing token or user for Pushover - cannot continue
do err_code = 1

if !err_code == 1 then goto end-script

goto get-data

:query-err:
echo Error: Failed to execute query
goto end-script

:check-err:
echo Error: Failed to extract insight
goto end-script

:telegram-err:
echo Error: Failed to send Telegram alert: !message
goto end-script

:pushover-err:
echo Error: Failed to send Pushover alert: !message
goto end-script


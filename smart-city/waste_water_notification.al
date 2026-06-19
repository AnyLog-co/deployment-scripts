#----------------------------------------------------------------------------------------------------------------------#
# Monitors smart-city waste water plant digital sensor fields and sends alerts when a value deviates from the expected
# state. Queries the most recent row from the alert table and checks each boolean field against expect_value
# (default: false). If a field deviates, an alert is sent via Telegram or Pushover before continuing to the next field.
# Smart city waste water notification — env-driven alert script
#
# Deploy: /app/deployment-scripts/smart-city/waste_water_plant.al
#
# Environment variables (optional unless noted):
#   ALERT_DB      — logical dbms (if unset, uses !default_dbms)
#   ALERT_TABLE   — table name (default: wwp_digital)
#   STALE_MINUTES — minutes without data = stale (default: 5)
#   EXPECT_VALUE  — alert when flag != this (default: false)
#   MSG_TYPE      — telegram or pushover (required)
#   MSG_URL       — notification API URL (required)
#   CHAT_ID       — Telegram chat id (required for telegram)
#   MSG_TOKEN     — Pushover app token (required for pushover)
#   MSG_USER      — Pushover user key (required for pushover)
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/smart-city/waste_water_notification.al

on error ignore

:set-params:
# specify all unique params here prior to `process command`
alert_table = wwp_digital

process !local_scripts/smart-city/notification_params.al

if !alert_db then selected_db = !alert_db
else selected_db = !default_dbms


:get-data:
on error goto query-err

stale_q = run client () sql !selected_db format=json:list and stat=false "select * from wwp_digital where timestamp >= NOW() - !stale_minutes minutes order by timestamp desc limit 1"

wait 35 for !stale_q
#get !stale_q

# No rows in stale window — notify and stop (repeat if on new line; do return fails after call)
if !stale_q == "" or !stale_q contains "Empty data set" then
do message = "Warning: NO DATA returned on " + !alert_table + " in " + !stale_minutes + " minutes - script will stop"
do print !message
do call send-msg
do goto end-script 

:check-data:
on error goto check-err

cur_v = from !stale_q(0) bring ['ss_screenrun_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=ss_screenrun_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['ss_jam_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=ss_jam_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_rasab2_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_rasab2_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_lf2_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_lf2_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_was1_thr_pb']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_was1_thr_pb value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_seq1a_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_seq1a_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_seq1b_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_seq1b_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_seq2a_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_seq2a_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_brfrng_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_brfrng_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_seq2b_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_seq2b_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_thickenera_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_thickenera_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_thickenera_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_thickenera_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['gk_shand_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=gk_shand_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_thickenerb_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_thickenerb_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_wf2_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_wf2_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_thickenerb_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_thickenerb_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_was1_tue_pb']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_was1_tue_pb value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_gfd1_s_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_gfd1_s_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_gfd2_s_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_gfd2_s_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_cabht1_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_cabht1_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_cabht2_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_cabht2_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_gen_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_gen_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_airpress_notok']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_airpress_notok value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['cg_a_in']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=cg_a_in value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_auger_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_auger_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_auger_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_auger_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_beltpress_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_beltpress_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_beltpress_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_beltpress_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['ss_hl_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=ss_hl_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_npwprng1_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_npwprng1_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_diga_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_diga_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_digb_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_digb_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_estop']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_estop value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_hfla_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_hfla_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_tstdbyrdy_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_tstdbyrdy_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_genrng_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_genrng_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_hflb_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_hflb_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_hvefrng_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_hvefrng_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_hvgas_a_in']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_hvgas_a_in value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_maindrum_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_maindrum_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_was1_wed_pb']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_was1_wed_pb value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_maindrum_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_maindrum_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_mx1_running']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_mx1_running value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_npwprng2_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_npwprng2_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_mx2_running']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_mx2_running value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['cg_fwdrev_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=cg_fwdrev_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_polymer_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_polymer_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_polymer_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_polymer_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_was1_fri_pb']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_was1_fri_pb value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_sludgepump_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_sludgepump_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_sludgepump_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_sludgepump_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_srg_ab_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_srg_ab_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['gk_classrng_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=gk_classrng_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_surge_high_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_surge_high_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_tanka_high_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_tanka_high_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_tankb_high_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_tankb_high_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['cg_start_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=cg_start_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_wasa_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_wasa_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_srfrng_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_srfrng_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_wasb_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_wasb_valve value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_waterpump_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_waterpump_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_was1_mon_pb']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_was1_mon_pb value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_waterpump_status']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_waterpump_status value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_tsnprdy_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_tsnprdy_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['gk_fvo_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=gk_fvo_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['mcc_tsstdby_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=mcc_tsstdby_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_was1_sat_pb']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_was1_sat_pb value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_lf1_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_lf1_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_was1_sun_pb']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_was1_sun_pb value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['gk_gsf_s_in']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=gk_gsf_s_in value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['gk_pmprng_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=gk_pmprng_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['ss_auto_s']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=ss_auto_s value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['uv_wf1_a_alarm']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=uv_wf1_a_alarm value=" + !cur_v
do call send-msg

cur_v = from !stale_q(0) bring ['am_rasab1_valve']
if !cur_v != !expect_value then
do message = "Waste Water plant ALERT name=am_rasab1_valve value=" + !cur_v
do call send-msg

print Waste Water plant ALERT completed sent=!sent_count
goto end-script

:send-msg:
if !msg_type == "telegram" then
do on error goto telegram-err
do telegram_body = json{"chat_id":!chat_id,"text":!message}
do rest post where url = !msg_url and headers = {"Content-Type":"application/json"} and body = !telegram_body
do sent_count = incr !sent_count
return

if !msg_type == "pushover" then
do on error goto pushover-err
do pushover_body = json{"token":!msg_token,"user":!msg_user,"message":!message }
do rest post where url = !msg_url and headers = {"Content-Type":"application/json"} and body = !pushover_body
do sent_count = incr !sent_count
return

print Unknown msg_type=!msg_type
return

:end-script:
print "Waste Water ALERT done"
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


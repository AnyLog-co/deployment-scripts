#-----------------------------------------------------------------------------------------------------------------------#
# Tear down stale basic_msg_client subscriptions and run the MSG_TOPIC data-generator handler.
# Called after config from policy and at the end of main.al so cached blockchain scripts cannot win.
#-----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/mqtt_post_config.al

on error ignore

if !enable_mqtt == false then goto end-script

echo "MQTT post-config: MSG_TOPIC=" + $MSG_TOPIC + " msg_topic=" + !msg_topic + " ledger_conn=" + !ledger_conn

wait 10
exit msg client all
process !local_scripts/data-generator/data_generator.al

:end-script:
end script

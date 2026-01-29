on error goto mqtt-error

:enterprise-root:
<run msg client where
	broker = !mqtt_broker and port=!mqtt_port and
	user = !mqtt_user and password = !mqtt_passwd and
	master_node = !ledger_conn and
	log = false and topic = (
		name="Enterprise B/Metric/#" and
		dbms=!default_dbms and
		dynamic = True
	)>

:end-script:
end script

:mqtt-error:
echo "Failed to start mqtt for Enterprise B/Metric/#"
goto end-script
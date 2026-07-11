:set-params:
# logical database or database and table combinations to check rather than all tables on the blockchain
alert_dbms = ""
alert_table = ""

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

data_nodes = get data nodes where format=json      # list of all data nodes on the network, incl. dbms/table/IP/port per node
keys = ""                                          # column keys of the current data_nodes entry, populated once from the first row

:check-data:
for loop start where list = !data_nodes
  alert_db = ""           # dbms name for the current node's table, extracted from "DBMS" key
  alert_table = ""        # table name for the current node's table, extracted from "Table" key
  alert_node = ""         # node address (IP/Port) to run the query against; prefers External, falls back to Local
  alert_node_name = ""    # display name of the node, extracted from "Node Name" key

  if not !keys then   keys = json !data_nodes[+] keys
  for loop start where list = !keys
     key = !keys[+]        # current column/key name being inspected for this node entry
     if !key == "DBMS"                  then alert_db = from !data_nodes[+] bring [!key]
     else if !key == "Table"            then alert_table = from !data_nodes[+] bring [!key]
     else if !key == "External IP/Port" then alert_node = from !data_nodes[+] bring [!key]
     else if not !alert_node and !key == "Local IP/Port" then alert_node = from !data_nodes[+] bring [!key]
     else if !key == "Node Name"        then alert_node_name = from !data_nodes[+] bring [!key]
   for loop end

   query_response = run client (!alert_node) sql !alert_db format=json:list and stat=false select count(*) as row_count from !alert_table where insert_timestamp >= NOW() - 1 hour
   wait 30 for !query_response        # Wait up to 30 seconds for this node's query to complete

   if not !query_response then end script
   for loop start where list = !query_response
        tmp_value = json !query_response[+] values  # row_count value(s) for this node's table
        if not !value
        do message = "Failed to gather row count for " + !alert_db + "." + !alert_table + " on: " + !node_name
        do goto send-msg
        value = !tmp_value[0]
        if !value.int <= 0 then
        do message = "No data has inserted in " + !alert_db + "." + !alert_table + " on: " + !node_name
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
else do pushover_body = json  {"token": !msg_token, "user": !msg_user, "message": !message}
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


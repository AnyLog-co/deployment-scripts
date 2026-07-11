#----------------------------------------------------------------------------------------------------------------------#
# Notifications regarding table/data availability run via the Query node, since it requires `system_query`
# request, scanning all relevant operator node(s).
#
# Unlike the blockchain-table-scan variant of this script, this version queries `get data nodes` directly to
# discover each node's dbms/table/address, and runs each check against the specific node hosting that data
# (via `run client (!alert_node) ...`) rather than letting the network route the query. This is useful when
# you need to confirm a specific physical node is responsive and has recent data, not just that data exists
# somewhere on the network.
#
# alert_dbms / alert_table act as an optional filter: leave both blank to check every node/table returned by
# `get data nodes`; set one or both to restrict the scan to a specific dbms and/or table.
#
# Message (msg_*) configs are defined once per script rather than centrally, since different scripts /
# deployments may need to route "no data" / "query failed" alerts to different chats or notification services.
#
#:notes:
#   - a node that fails to respond to its query is now reported via send-msg (as a failure alert) and the
#     script continues on to the next node, rather than terminating the entire run.
#   - adjust the 1-hour staleness window in the query below if a different window is needed; consider adding
#     an `alert_window` param if this needs to be configurable without editing the query line directly.
#
#:steps:
#   1. optionally set alert_dbms / alert_table to restrict which node(s) get checked
#   2. configure msg_type / msg_url / chat_id / msg_token / msg_user for the desired notification target
#   3. run as a scheduled process
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/notifications/row_count.al

on error ignore

:set-params:
# optional filter configs — leave blank to check every dbms/table returned by `get data nodes`
alert_dbms = ""    # if set, restrict the scan to nodes serving this dbms (matched against each node's "DBMS" key)
alert_table = ""   # if set, restrict the scan to nodes serving this table (matched against each node's "Table" key)

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
  node_dbms = ""          # dbms name for the current node's table, extracted from "DBMS" key
  node_table = ""         # table name for the current node's table, extracted from "Table" key
  alert_node = ""         # node address (IP/Port) to run the query against; prefers External, falls back to Local
  alert_node_name = ""    # display name of the node, extracted from "Node Name" key

  if not !keys then   keys = json !data_nodes[+] keys
  for loop start where list = !keys
     key = !keys[+]        # current column/key name being inspected for this node entry
     if !key == "DBMS"                  then node_dbms = from !data_nodes[+] bring [!key]
     else if !key == "Table"            then node_table = from !data_nodes[+] bring [!key]
     else if !key == "External IP/Port" then alert_node = from !data_nodes[+] bring [!key]
     else if not !alert_node and !key == "Local IP/Port" then alert_node = from !data_nodes[+] bring [!key]
     else if !key == "Node Name"        then alert_node_name = from !data_nodes[+] bring [!key]
   for loop end

   # skip this node if it doesn't match the optional alert_dbms / alert_table filters
   if !alert_dbms and !node_dbms != !alert_dbms then goto next-node
   if !alert_table and !node_table != !alert_table then goto next-node

   query_response = run client (!alert_node) sql !node_dbms format=json:list and stat=false select count(*) as row_count from !node_table where insert_timestamp >= NOW() - 1 hour
   wait 30 for !query_response        # Wait up to 30 seconds for this node's query to complete

   if not !query_response then
   do message = "Failed to query " + !node_dbms + "." + !node_table + " on: " + !alert_node_name
   do call send-msg
   do goto next-node

   for loop start where list = !query_response
        tmp_value = json !query_response[+] values  # raw row_count value(s) for this node's table
        if not !tmp_value then
        do message = "Failed to gather row count for " + !node_dbms + "." + !node_table + " on: " + !alert_node_name
        do call send-msg
        else do value = !tmp_value[0]                # extracted row_count as a scalar
        if !value and !value.int <= 0 then
        do message = "No data has inserted in " + !node_dbms + "." + !node_table + " on: " + !alert_node_name
        do call send-msg
   for loop end

   :next-node:
for loop end

goto end-script

:send-msg:
if !msg_type == telegram then
do on error goto telegram-err
do telegram_body = json {"chat_id": !chat_id, "text": !message}
do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !telegram_body

else if !msg_type == pushover then
do on error goto pushover-err
do pushover_body = json {"token": !msg_token, "user": !msg_user, "message": !message}
do rest post where url = !msg_url and headers = {"Content-Type": "application/json"} and body = !pushover_body

else goto missing-type

return

:end-script:
end script

:terminate-scripts:
exit scripts

:telegram-err:
echo "Error: Failed to send Telegram alert: !message"
goto terminate-scripts

:pushover-err:
echo "Error: Failed to send Pushover alert: !message"
goto terminate-scripts

:missing-type:
echo "Error: Invalid message type: " !msg_type
goto terminate-scripts
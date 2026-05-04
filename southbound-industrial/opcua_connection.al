#----------------------------------------------------------------------------------------------------------------------#
# Main for running OPC-UA service
# :process:
# 1. define tags
# 2. declare OPC-UA client
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial-opcua/main.al

set debug on

on error ignore

if  !opcua_name then
do file_opcua_tags = python !opcua_name.strip().replace(" ", "_").replace("-", "_") + "_tags.al"
do file_opcua_client = python !opcua_name.strip().replace(" ", "_").replace("-", "_") + "_client.al"
else
do file_opcua_tags = python !opcua_url.strip().split("//")[-1].replace(".", "_").replace(":","_") + "_tags".al
do file_opcua_client = python !opcua_url.strip().split("//")[-1].replace(".", "_").replace(":","_") + "_tags".al


:define-tags:
on error call define-tags-err
is_file = file test !local_scripts/southbound-industrial-opcua/!file_opcua_tags
if !is_file == true then goto process-tags
if !opcua_username or !opcua_password then goto define-tags-auth

<get opcua struct where
    url = !opcua_url and
    node = !opcua_node and
    dbms = !default_dbms and
    format = policy  and
    schema = true and
    class = variable and
    target = "local = true and master = !ledger_conn" and
    output = !local_scripts/southbound-industrial-opcua/my_tag.al>

goto process-tags

:define-tags-auth:
<get opcua struct where
    url = !opcua_url and
    user = !opcua_username and
    password = !opcua_password and
    node = !opcua_node and
    dbms = !default_dbms and
    format = policy  and
    schema = true and
    class = variable and
    target = "local = true and master = !ledger_conn" and
    output = !local_scripts/southbound-industrial-opcua/my_tag.al>

:process-tags:
on error ignore

is_file = if test !file_opcua_tags
if not !is_file goto missing-file-tags
process !local_scripts/southbound-industrial-opcua/!file_opcua_tags

:define-client:

:declare-client:
on error call declare-client-err
is_file = file test !local_scripts/southbound-industrial-opcua/!file_opcua_client
if !is_file == true then goto process-client
if !opcua_username or !opcua_password then goto define-client-auth

<get opcua struct where
    url = !opcua_url and
    node = !opcua_node and
    dbms = !default_dbms and
    frequency = !opcua_frequency and
    format = run_client  and
    class = variable and
    name=opcua-client1 and
    output = !local_scripts/southbound-industrial-opcua/!file_opcua_client>


:define-client-auth:
<get opcua struct where
    url = !opcua_url and
    user = !opcua_username and
    password = !opcua_password and
    node = !opcua_node and
    dbms = !default_dbms and
    frequency = !opcua_frequency and
    format = run_client  and
    class = variable and
    name=opcua-client1 and
    output = !local_scripts/southbound-industrial-opcua/!file_opcua_client>

:process-client:
on error ignore

is_file = if test !file_opcua_client
if not !is_file goto missing-file-client
process !local_scripts/southbound-industrial-opcua/!file_opcua_client


:end-script:
end-script

:missing-file-tags:
echo "Failed to create !file_opcua_tags file - cannot continue"
goto end-script

:missing-file-client:
echo "Failed to create !file_opcua_client file - cannot continue"
goto end-script

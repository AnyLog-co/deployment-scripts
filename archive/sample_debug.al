#-----------------------------------------------------------------------------------------------------------------------
# The following demonstrates using the debug mode in order to test specific script.
# - `set debug on` will run the script line by line
# - `set debug interactive` will require user to call `next` after each line
#
# requirement: set debug_mode (as integer)
#   - 0 will run as is
#   - 1 will run in `set debug on`
#   - 2 will run in `set debug interactive`
#-----------------------------------------------------------------------------------------------------------------------
# for option 0 and 1 - process deployment-scripts/demo-scripts/sample_debug.al
# for option 2 - thread deployment-scripts/demo-scripts/sample_debug.al

:set-params:
on error ignore
if !debug_mode.int == 1 then set debug on
if !debug_mode.int == 2 then set debug interactive

rand_value = 1

:if-else-demo:
if !rand_value == 1 then
do call part-1-message
do goto if-else-demo
else if !rand_value == 3 then goto part-3-message
else do print "Rand Value is 2"
do rand_value = 3
do goto if-else-demo

:end-script:
end script


:part-1-message:
print "Message 1 - showing sample call / return"
rand_value = 2
return

:part-3-message:
print "Ending Demo"
goto end-script


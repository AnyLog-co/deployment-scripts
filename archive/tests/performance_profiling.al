#------------------------------------------------------------------------------------------------------------------------
# Sample code to profile performance
# :target options:
#   - operator
#   - put
#   - post
#------------------------------------------------------------------------------------------------------------------------
# process !root_dir/tests/performance_profiling.al

on error ignore
if $PROFILER != true then goto profile-error
if not !target then set target = operator

if !profiler_status == start then set profiler on where target = !target
else set profiler off where target = !target
if !profiler_status == summary then get profiler output where target = !target

:end-script
end script

:profile-error:
print "failed to enable profiler"
goto end-script
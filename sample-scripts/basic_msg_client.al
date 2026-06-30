#--------------------------------------------------------------------------------------------------------------#
# Legacy hook — cached config policies still call this path. Route to the topic-specific MQTT handlers.
#--------------------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/basic_msg_client.al

on error ignore

exit msg client all
process !local_scripts/data-generator/data_generator.al

:end-script:
end script

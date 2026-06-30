#--------------------------------------------------------------------------------------------------------------#
# Legacy hook — older cached config policies reference connectors/basic_msg_client.al
#--------------------------------------------------------------------------------------------------------------#
# process !local_scripts/connectors/basic_msg_client.al

on error ignore

exit msg client all
process !local_scripts/data-generator/data_generator.al

:end-script:
end script

#-----------------------------------------------------------------------------------------------------------------------
# Optional user hook — runs last in the config-policy script list.
# MQTT is started once from mqtt_post_config.al after config from policy (not here).
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/local_script.al

on error ignore

:end-script:
end script

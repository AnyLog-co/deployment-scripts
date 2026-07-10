#--------------------------------------------------------------------------------------------------------------------#
# Mapping policy for vessel data
#--------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/mapping/vessel_BATTERY-PACK-DEVICE-LOGS.al
on error ignore



set create_policy = false

:check-policy:
is_policy = blockchain get (mapping, transform) where id = BATTERY-PACK-DEVICE-LOGS
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto end-script
else if not !is_policy and !create_policy == true then goto declare-policy-error


:declare-policy:
<new_policy = {
    "mapping" : {
        "id" : "BATTERY-PACK-DEVICE-LOGS",
        "dbms" : !msg_dbms,
        "table" : "battery_pack_device_logs",
        "readings" : "",
        "schema" : {
            "timestamp" : {
                "type" : "timestamp",
                "default" : "now()",
                "bring" : "[timestamp]"
            },
            "boat_name" : {
                "type" : "string",
                "bring" : "[boat_name]",
                "default" : ""
            },
            "side" : {
                "type" : "string",
                "bring" : "[side]",
                "default" : ""
            },
            "ip_index" : {
                "type" : "int",
                "bring" : "[ip_index]",
                "default" : Null
            },
            "motor_id" : {
                "type" : "int",
                "bring" : "[motor_id]",
                "default" : Null
            },
            "__start__" : {"script" : ["set BATTERY-PACK-DEVICE-LOGS_counter = 0"]
            },
            "actualSoc" : {
                "type" : "float",
                "bring" : "[actualSoc]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [actualSoc] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualUserSoc" : {
                "type" : "float",
                "bring" : "[actualUserSoc]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [actualUserSoc] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualSocDelta" : {
                "type" : "string",
                "bring" : "[actualSocDelta]",
                "default" : "",
                "optional" : True,
                "script" : ["if [actualSocDelta] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "maxSocAllowed_StateOfHealth" : {
                "type" : "float",
                "bring" : "[maxSocAllowed_StateOfHealth]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [maxSocAllowed_StateOfHealth] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "minSocAllowed" : {
                "type" : "float",
                "bring" : "[minSocAllowed]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [minSocAllowed] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualPackVoltage" : {
                "type" : "float",
                "bring" : "[actualPackVoltage]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [actualPackVoltage] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualBusVoltage" : {
                "type" : "int",
                "bring" : "[actualBusVoltage]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [actualBusVoltage] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualCurrent" : {
                "type" : "float",
                "bring" : "[actualCurrent]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [actualCurrent] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "maxCapacity" : {
                "type" : "float",
                "bring" : "[maxCapacity]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [maxCapacity] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "maxVoltageCharge" : {
                "type" : "float",
                "bring" : "[maxVoltageCharge]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [maxVoltageCharge] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "minVoltageDischarge" : {
                "type" : "float",
                "bring" : "[minVoltageDischarge]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [minVoltageDischarge] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "maxCurrentCharge" : {
                "type" : "float",
                "bring" : "[maxCurrentCharge]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [maxCurrentCharge] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "maxCurrentDischarge" : {
                "type" : "int",
                "bring" : "[maxCurrentDischarge]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [maxCurrentDischarge] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "maxCellVoltage" : {
                "type" : "float",
                "bring" : "[maxCellVoltage]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [maxCellVoltage] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "minCellVoltage" : {
                "type" : "float",
                "bring" : "[minCellVoltage]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [minCellVoltage] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "cellBalance" : {
                "type" : "float",
                "bring" : "[cellBalance]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [cellBalance] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "availablePowerChargeLong" : {
                "type" : "float",
                "bring" : "[availablePowerChargeLong]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [availablePowerChargeLong] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "availablePowerChargeShort" : {
                "type" : "float",
                "bring" : "[availablePowerChargeShort]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [availablePowerChargeShort] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "availablePowerDischargeLong" : {
                "type" : "float",
                "bring" : "[availablePowerDischargeLong]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [availablePowerDischargeLong] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "availablePowerDischargeShort" : {
                "type" : "float",
                "bring" : "[availablePowerDischargeShort]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [availablePowerDischargeShort] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualTempBattery" : {
                "type" : "int",
                "bring" : "[actualTempBattery]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [actualTempBattery] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualTempBatteryMax" : {
                "type" : "string",
                "bring" : "[actualTempBatteryMax]",
                "default" : "",
                "optional" : True,
                "script" : ["if [actualTempBatteryMax] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualTempBatteryMin" : {
                "type" : "string",
                "bring" : "[actualTempBatteryMin]",
                "default" : "",
                "optional" : True,
                "script" : ["if [actualTempBatteryMin] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "actualTempHeatexchanger" : {
                "type" : "int",
                "bring" : "[actualTempHeatexchanger]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [actualTempHeatexchanger] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "coolingRequested" : {
                "type" : "string",
                "bring" : "[coolingRequested]",
                "default" : "",
                "optional" : True,
                "script" : ["if [coolingRequested] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "coolingRequestedPower" : {
                "type" : "string",
                "bring" : "[coolingRequestedPower]",
                "default" : "",
                "optional" : True,
                "script" : ["if [coolingRequestedPower] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "coolingType" : {
                "type" : "string",
                "bring" : "[coolingType]",
                "default" : "",
                "optional" : True,
                "script" : ["if [coolingType] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "coolingWorking" : {
                "type" : "string",
                "bring" : "[coolingWorking]",
                "default" : "",
                "optional" : True,
                "script" : ["if [coolingWorking] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "coolingValveState" : {
                "type" : "string",
                "bring" : "[coolingValveState]",
                "default" : "",
                "optional" : True,
                "script" : ["if [coolingValveState] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "coolingValveRequest" : {
                "type" : "string",
                "bring" : "[coolingValveRequest]",
                "default" : "",
                "optional" : True,
                "script" : ["if [coolingValveRequest] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "coolingValveErrorState" : {
                "type" : "string",
                "bring" : "[coolingValveErrorState]",
                "default" : "",
                "optional" : True,
                "script" : ["if [coolingValveErrorState] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvOperationState" : {
                "type" : "string",
                "bring" : "[ekmvOperationState]",
                "default" : "",
                "optional" : True,
                "script" : ["if [ekmvOperationState] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvTemp" : {
                "type" : "int",
                "bring" : "[ekmvTemp]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [ekmvTemp] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvTempIn" : {
                "type" : "int",
                "bring" : "[ekmvTempIn]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [ekmvTempIn] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvTempOut" : {
                "type" : "int",
                "bring" : "[ekmvTempOut]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [ekmvTempOut] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvPresHigh" : {
                "type" : "float",
                "bring" : "[ekmvPresHigh]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [ekmvPresHigh] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvPresLow" : {
                "type" : "int",
                "bring" : "[ekmvPresLow]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [ekmvPresLow] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvRpmPercent" : {
                "type" : "float",
                "bring" : "[ekmvRpmPercent]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [ekmvRpmPercent] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvEpower" : {
                "type" : "int",
                "bring" : "[ekmvEpower]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [ekmvEpower] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "ekmvErrorState" : {
                "type" : "string",
                "bring" : "[ekmvErrorState]",
                "default" : "",
                "optional" : True,
                "script" : ["if [ekmvErrorState] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "stateContactor" : {
                "type" : "string",
                "bring" : "[stateContactor]",
                "default" : "",
                "optional" : True,
                "script" : ["if [stateContactor] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "stateDischargeBus" : {
                "type" : "string",
                "bring" : "[stateDischargeBus]",
                "default" : "",
                "optional" : True,
                "script" : ["if [stateDischargeBus] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "stateErrorContactor" : {
                "type" : "string",
                "bring" : "[stateErrorContactor]",
                "default" : "",
                "optional" : True,
                "script" : ["if [stateErrorContactor] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "stateErrorExternalIsolation" : {
                "type" : "string",
                "bring" : "[stateErrorExternalIsolation]",
                "default" : "",
                "optional" : True,
                "script" : ["if [stateErrorExternalIsolation] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "stateErrorInternalIsolation" : {
                "type" : "string",
                "bring" : "[stateErrorInternalIsolation]",
                "default" : "",
                "optional" : True,
                "script" : ["if [stateErrorInternalIsolation] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "stateWarnIsolation" : {
                "type" : "string",
                "bring" : "[stateWarnIsolation]",
                "default" : "",
                "optional" : True,
                "script" : ["if [stateWarnIsolation] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "statusWarnOverTemp" : {
                "type" : "string",
                "bring" : "[statusWarnOverTemp]",
                "default" : "",
                "optional" : True,
                "script" : ["if [statusWarnOverTemp] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "isoMeasurementActive" : {
                "type" : "string",
                "bring" : "[isoMeasurementActive]",
                "default" : "",
                "optional" : True,
                "script" : ["if [isoMeasurementActive] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "requestAbortCharging" : {
                "type" : "string",
                "bring" : "[requestAbortCharging]",
                "default" : "",
                "optional" : True,
                "script" : ["if [requestAbortCharging] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "requestContactorClose" : {
                "type" : "string",
                "bring" : "[requestContactorClose]",
                "default" : "",
                "optional" : True,
                "script" : ["if [requestContactorClose] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "requestInterruptCharging" : {
                "type" : "string",
                "bring" : "[requestInterruptCharging]",
                "default" : "",
                "optional" : True,
                "script" : ["if [requestInterruptCharging] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "requestOpenContactorFast" : {
                "type" : "string",
                "bring" : "[requestOpenContactorFast]",
                "default" : "",
                "optional" : True,
                "script" : ["if [requestOpenContactorFast] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "requestOpenContactorNow" : {
                "type" : "string",
                "bring" : "[requestOpenContactorNow]",
                "default" : "",
                "optional" : True,
                "script" : ["if [requestOpenContactorNow] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "timeToFullMinute" : {
                "type" : "int",
                "bring" : "[timeToFullMinute]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [timeToFullMinute] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "predictedChargeTimeMinute" : {
                "type" : "string",
                "bring" : "[predictedChargeTimeMinute]",
                "default" : "",
                "optional" : True,
                "script" : ["if [predictedChargeTimeMinute] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "batteryType" : {
                "type" : "string",
                "bring" : "[batteryType]",
                "default" : "",
                "optional" : True,
                "script" : ["if [batteryType] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "deviceState" : {
                "type" : "string",
                "bring" : "[deviceState]",
                "default" : "",
                "optional" : True,
                "script" : ["if [deviceState] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "deviceEnableSetting" : {
                "type" : "string",
                "bring" : "[deviceEnableSetting]",
                "default" : "",
                "optional" : True,
                "script" : ["if [deviceEnableSetting] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "deviceIdentification" : {
                "type" : "int",
                "bring" : "[deviceIdentification]",
                "default" : Null,
                "optional" : True,
                "script" : ["if [deviceIdentification] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "error" : {
                "type" : "string",
                "bring" : "[error]",
                "default" : "",
                "optional" : True,
                "script" : ["if [error] then BATTERY-PACK-DEVICE-LOGS_counter = incr !BATTERY-PACK-DEVICE-LOGS_counter"]
            },
            "__end__" : {"script" : ["if !BATTERY-PACK-DEVICE-LOGS_counter == 0 then streaming data ignore event"]}
        }
   }
}>

:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts

on error ignore

:set-params:
policy_id = schneider
set create_policy = false

:check-policy:
is_policy = blockchain get (mapping, transform) where id = !policy_id
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto msg-client
else if not !is_policy and !create_policy == true then goto declare-policy-error

:declare-policy:
<new_policy = {"mapping": {
    "id": "schneider",
    "dbms": !default_dbms,
    "table": "station_obs",
    "readings": "",
    "schema": {
      "timestamp": {
        "type": "timestamp",
        "default": "now()",
        "bring": "[timestamp]",
        "optional": true
      },
      "station_id": {
        "type": "string",
        "default": null,
        "bring": "[station_id]",
        "optional": true
      },
      "wind_speed_ms": {
        "type": "float",
        "default": null,
        "bring": "[wind][speed_ms]",
        "optional": true
      },
      "wind_speed_mph": {
        "type": "float",
        "default": null,
        "bring": "[wind][speed_mph]",
        "optional": true
      },
      "wind_direction_deg": {
        "type": "float",
        "default": null,
        "bring": "[wind][direction_deg]",
        "optional": true
      },
      "wind_direction_cardinal": {
        "type": "string",
        "default": null,
        "bring": "[wind][direction_cardinal]",
        "optional": true
      },
      "wind_gust_ms_10min": {
        "type": "float",
        "default": null,
        "bring": "[wind][gust_ms_10min]",
        "optional": true
      },
      "air_temperature_c": {
        "type": "float",
        "default": null,
        "bring": "[air][temperature_c]",
        "optional": true
      },
      "air_temperature_f": {
        "type": "float",
        "default": null,
        "bring": "[air][temperature_f]",
        "optional": true
      },
      "air_humidity_pct": {
        "type": "float",
        "default": null,
        "bring": "[air][humidity_pct]",
        "optional": true
      },
      "air_dewpoint_c": {
        "type": "float",
        "default": null,
        "bring": "[air][dewpoint_c]",
        "optional": true
      },
      "air_heat_index_f": {
        "type": "float",
        "default": null,
        "bring": "[air][heat_index_f]",
        "optional": true
      },
      "pressure_station_hpa": {
        "type": "float",
        "default": null,
        "bring": "[pressure][station_hpa]",
        "optional": true
      },
      "pressure_sealevel_hpa": {
        "type": "float",
        "default": null,
        "bring": "[pressure][sealevel_hpa]",
        "optional": true
      },
      "pressure_trend_3hr": {
        "type": "string",
        "default": null,
        "bring": "[pressure][trend_3hr]",
        "optional": true
      },
      "rain_rate_mm_hr": {
        "type": "float",
        "default": null,
        "bring": "[rain][rate_mm_hr]",
        "optional": true
      },
      "rain_accum_10min_mm": {
        "type": "float",
        "default": null,
        "bring": "[rain][accum_10min_mm]",
        "optional": true
      },
      "rain_accum_1hr_mm": {
        "type": "float",
        "default": null,
        "bring": "[rain][accum_1hr_mm]",
        "optional": true
      },
      "rain_accum_24hr_mm": {
        "type": "float",
        "default": null,
        "bring": "[rain][accum_24hr_mm]",
        "optional": true
      },
      "rain_tips_since_boot": {
        "type": "int",
        "default": null,
        "bring": "[rain][tips_since_boot]",
        "optional": true
      },
      "quality_battery_v": {
        "type": "float",
        "default": null,
        "bring": "[quality][battery_v]",
        "optional": true
      },
      "quality_solar_charging": {
        "type": "bool",
        "default": null,
        "bring": "[quality][solar_charging]",
        "optional": true
      },
      "quality_sensor_status": {
        "type": "string",
        "default": null,
        "bring": "[quality][sensor_status]",
        "optional": true
      }
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

:msg-client:
on error goto msg-client-err
<run msg client where broker=local and master_node=!ledger_conn and log=false and topic=(
    name="schneider/weatherstation/#" and
    policy=!policy_id and
    dynamic=true
)>

:end-script:
end script

:terminate-scripts:
exit scripts

:msg-client-err:
print "Failed to defined msg client"
goto terminate-scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts

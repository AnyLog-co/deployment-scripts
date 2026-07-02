# Smart City Scripts

**This is live data**, not a synthetic demo feed — the data comes from real operational power, water, and waste-water 
plants out in Kansas. The plant operators have generously agreed to let their live MQTT streams be used as a demo / test 
bed for this project, so treat the broker and credentials in the plant scripts as pointing at an actual production data 
source, not a sandbox.

Each utility (water, waste water) has matching **plant** (ingest) and **notification** (alert) scripts, plus one 
top-level script that schedules all the notification jobs.


## How it fits together

```
            ┌────────────────────────┐
 MQTT  ───▶ │   *_plant.al           │  ingest readings → AnyLog tables
broker      │ (power / water / wwp)  │  (pp_pm, pv, wp_analog, wp_digital,
            └────────────────────────┘   wwp_analog, wwp_digital)
                        │
                        ▼
            ┌────────────────────────┐
            │ *_notification.al      │  query latest/recent rows,
            │ (power / water / wwp,  │  compare to expected state or
            │  digital / analog)     │  check for staleness
            └────────────────────────┘
                        │
                        ▼
                  Telegram / Pushover alert

smart_city_notification.al schedules the *_notification.al
scripts to run on a recurring timer.
```

Power only gets a row-count/staleness notification (no digital/analog split, no per-field threshold checks) — 
there's no `pp_pm`/`pv` equivalent of the water/waste-water "digital" alert.

## Plant scripts (MQTT ingestion)

All three connect to the same MQTT broker (`172.104.228.251:1883`) and map incoming JSON fields to AnyLog table columns via `bring [...]`.

- **Power** (`smart_city_power_plant.al`) → `pp_pm`, `pv`
- **Water** (`smart_city_water_plant.al`) → `wp_analog`, `wp_digital`
- **Waste water** (`smart_city_waste_water_plant.al`) → `wwp_analog`, `wwp_digital`

Broker credentials are currently hardcoded in each script (`user=anyloguser`, `password=mqtt4AnyLog!`) — update these together if the broker or credentials change, since all three scripts duplicate the same connection block.

## Notification scripts (alerting)

Digital (`*_notification.al`) and analog (`*_analog_notification.al`) scripts share the same env-driven pattern:

| Variable | Required | Default | Meaning |
|---|---|---|---|
| `ALERT_DB` | no | `!default_dbms` | logical database to query |
| `ALERT_TABLE` | no | `wp_digital` / `wwp_digital` / `wp_analog` / `wwp_analog` per script | table to query |
| `STALE_MINUTES` (digital) / `STABLE_MINUTES` (analog) | no | 5 min (digital) / 30 min (analog) | how far back to look for data before flagging it stale |
| `EXPECT_VALUE` | no (digital only) | `false` | the value each boolean field is expected to hold |
| `MSG_TYPE` | yes | — | `telegram` or `pushover` |
| `MSG_URL` | yes | — | notification API endpoint |
| `CHAT_ID` | required if `MSG_TYPE=telegram` | — | Telegram chat ID |
| `MSG_TOKEN` | required if `MSG_TYPE=pushover` | — | Pushover app token |
| `MSG_USER` | required if `MSG_TYPE=pushover` | — | Pushover user key |

- **Digital** notification scripts (`smart_city_water_notification.al`, `smart_city_waste_water_notification.al`) pull the most recent row and alert on each boolean column that doesn't match `EXPECT_VALUE`, plus a stale-data warning if no row exists in the window.
- **Analog/row-count** notification scripts (`smart_city_water_analog_notification.al`, `smart_city_waste_water_analog_notification.al`, `smart_city_power_notification.al`) only check whether any row exists in the lookback window — there's no per-field threshold check, just a stale-data alert.

### Shared params include

Each notification script's `:set-params:` section now follows this pattern:

```
:set-params:
# specify all unique params here prior to `process command`
alert_table = wwp_digital

process !local_scripts/smart-city/notification_params.al

if !alert_db then selected_db = !alert_db
else selected_db = !default_dbms
```

The script sets whatever values are unique to *it* (at minimum `alert_table`) and then hands off to the shared `notification_params.al` include, which handles the common boilerplate — reading the `$ALERT_DB`, `$STALE_MINUTES`/`$STABLE_MINUTES`, `$EXPECT_VALUE`, `$MSG_TYPE`, `$MSG_URL`, `$CHAT_ID`, `$MSG_TOKEN`, `$MSG_USER` environment overrides and falling back to defaults. After the `process` call returns, the script picks `selected_db` from whatever `alert_db` the include resolved.

**Important — per-plant/service config:** because the defaults and env-var handling live in one shared include, there's no way to give each plant/service its own default `STALE_MINUTES`, `EXPECT_VALUE`, etc. purely through environment variables if you want those defaults to differ *per script*. If you need unique config per plant (e.g. waste water should alert at 10 minutes stale but water at 5), you have to open that specific notification script and hardcode the override directly in its own `:set-params:` block, above the `process` call to `notification_params.al` — the same way `alert_table` is already set there. The shared include only fills in what wasn't already set by the calling script.

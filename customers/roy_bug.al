<run msg client where
  broker = local and
  log = false and
  master_node = !ledger_conn and
  topic = (
    name = smartcity/metroville/power/west-power-plant/generators/# and
    dbms = default_dbms and
    table = "power_generator_telemetry" and
    column.schema_version = (type = int and value = "bring [schema_version]") and
    column.timestamp.timestamp = "bring [timestamp]" and
    column.city_id = (type = str and value = "bring [city_id]") and
    column.facility_id = (type = str and value = "bring [facility_id]") and
    column.device_id = (type = str and value = "bring [device_id]") and
    column.asset_type = (type = str and value = "bring [asset_type]") and
    column.sequence = (type = int and value = "bring [sequence]") and
    column.latitude = (type = float and value = "bring [latitude]") and
    column.longitude = (type = float and value = "bring [longitude]") and
    column.sample_period_seconds = (type = float and value = "bring [sample_period_seconds]") and
    column.status = (type = str and value = "bring [status]") and
    column.alarm = (type = str and value = "bring [alarm]") and
    column.fuel_type = (type = str and value = "bring [fuel_type]") and
    column.capacity_kw = (type = float and value = "bring [capacity_kw]") and
    column.active_power_kw = (type = float and value = "bring [active_power_kw]") and
    column.reactive_power_kvar = (type = float and value = "bring [reactive_power_kvar]") and
    column.voltage_v = (type = float and value = "bring [voltage_v]") and
    column.current_a = (type = float and value = "bring [current_a]") and
    column.frequency_hz = (type = float and value = "bring [frequency_hz]") and
    column.power_factor = (type = float and value = "bring [power_factor]") and
    column.temperature_c = (type = float and value = "bring [temperature_c]") and
    column.fuel_level_pct = (type = float and value = "bring [fuel_level_pct]") and
    column.cumulative_energy_kwh = (type = float and value = "bring [cumulative_energy_kwh]") and
    dynamic = true
  )>
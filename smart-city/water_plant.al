#
<run msg client where
    broker=!mqtt_broker and port=!mqtt_port and
    user=!mqtt_user and password=!mqtt_passwd and
    log=!msg_log and topic=(
        name=wp-analog and
        dbms=!default_dbms and
        table=wp_analog and
        column.timestamp.timestamp = "bring [timestamp]"  and
        column.chemicalscale1ai_pv = (type=float and value="bring [ChemicalScale1AI_PV]") and
        column.chemicalscale2ai_pv = (type=float and value="bring [ChemicalScale2AI_PV]") and
        column.chemicalscale3ai_pv = (type=float and value="bring [ChemicalScale3AI_PV]") and
        column.chemicalscale4ai_pv = (type=float and value="bring [ChemicalScale4AI_PV]") and
        column.phai_pv = (type=float and value="bring [pHAI_PV]") and
        column.combinedchlorinatorai_pv = (type=float and value="bring [CombinedChlorinatorAI_PV]") and
        column.freechlorinatorai_pv = (type=float and value="bring [FreeChlorinatorAI_PV]") and
        column.rawwatermeterai_pv = (type=float and value="bring [RawWaterMeterAI_PV]") and
        column.watertowerlevelai_pv = (type=float and value="bring [WaterTowerLevelAI_PV]") and
        column.combinedturbidityai_pv = (type=float and value="bring [CombinedTurbidityAI_PV]") and
        column.filter1turbidityai_pv = (type=float and value="bring [Filter1TurbidityAI_PV]") and
        column.filter2turbidityai_pv = (type=float and value="bring [Filter2TurbidityAI_PV]") and
        column.filter3turbidityai_pv = (type=float and value="bring [Filter3TurbidityAI_PV]") and
        column.rawwatermetertotalizer_curday = (type=float and value="bring [RawWaterMeterTotalizer_CurDay]") and
        column.rawwatermetertotalizer_yesday = (type=float and value="bring [RawWaterMeterTotalizer_YesDay]") and
        column.carbonfeeder_speedai_pv = (type=float and value="bring [CarbonFeeder_SpeedAI_PV]")
    ) and topic =(
        name=wp-digital and
        dbms=!default_dbms and
        table=wp_digital and
        column.timestamp.timestamp = "bring [timestamp]"  and
        column.atsnormalrdydi = (type=bool and value="bring [ATSNormalRdyDI]") and
        column.atsonstandbydi = (type=bool and value="bring [ATSOnStandbyDI]") and
        column.atsstandybyrdydi = (type=bool and value="bring [ATSStandyByRdyDI]") and
        column.clearwellhighleveldi = (type=bool and value="bring [ClearWellHighLevelDI]") and
        column.clearwelllowleveldi = (type=bool and value="bring [ClearWellLowLevelDI]") and
        column.generatoralarmdi = (type=bool and value="bring [GeneratorAlarmDI]") and
        column.generatorstatusdi = (type=bool and value="bring [GeneratorStatusDI]") and
        column.oxygenmonitordi = (type=bool and value="bring [OxygenMonitorDI]") and
        column.plantrunningdi = (type=bool and value="bring [PlantRunningDI]") and
        column.plantstartdi = (type=bool and value="bring [PlantStartDI]") and
        column.servicepump1running_di = (type=bool and value="bring [ServicePump1Running_DI]") and
        column.servicepump2running_di = (type=bool and value="bring [ServicePump2Running_DI]") and
        column.plantshutdowndo = (type=bool and value="bring [PlantShutdownDO]") and
        column.watertowerlevelcommsdi = (type=bool and value="bring [WaterTowerLevelCommsDI]") and
        column.plantenablechemicalsdo = (type=bool and value="bring [PlantEnableChemicalsDO]") and
        column.combinedchlorinatorvacdi = (type=bool and value="bring [CombinedChlorinatorVacDI]") and
        column.freechlorinatorvacdi = (type=bool and value="bring [FreeChlorinatorVacDI]") and
        column.carbonfeeder_runningfwd = (type=bool and value="bring [CarbonFeeder_RunningFwd]")
    )>
<run msg client where
    broker=172.104.228.251 and port=1883 and
    user=anyloguser and password=mqtt4AnyLog! and
    log=false and topic=(
        name=wp-analog and
        dbms=!default_dbms and
        table=wp_analog and
        column.timestamp.timestamp = "bring [timestamp]"  and
        column.chemicalscale1ai_pv = (type=float and bring="[]") and
        column.chemicalscale2ai_pv = (type=float and bring="[]") and
        column.chemicalscale3ai_pv = (type=float and bring="[]") and
        column.chemicalscale4ai_pv = (type=float and bring="[]") and
        column.phai_pv = (type=float and bring="[]") and
        column.combinedchlorinatorai_pv = (type=float and bring="[]") and
        column.freechlorinatorai_pv = (type=float and bring="[]") and
        column.rawwatermeterai_pv = (type=float and bring="[]") and
        column.watertowerlevelai_pv = (type=float and bring="[]") and
        column.combinedturbidityai_pv = (type=float and bring="[]") and
        column.filter1turbidityai_pv = (type=float and bring="[]") and
        column.filter2turbidityai_pv = (type=float and bring="[]") and
        column.filter3turbidityai_pv = (type=float and bring="[]") and
        column.rawwatermetertotalizer_curday = (type=float and bring="[]") and
        column.rawwatermetertotalizer_yesday = (type=float and bring="[]") and
        column.carbonfeeder_speedai_pv = (type=float and bring="[]")
    ) and topic =(
        name=wp-digital and
        dbms=!default_dbms and
        table=wp_digital and
        column.timestamp.timestamp = "bring [timestamp]"  and
        column.atsnormalrdydi = (type=bool and bring="[]") and
        column.atsonstandbydi = (type=bool and bring="[]") and
        column.atsstandybyrdydi = (type=bool and bring="[]") and
        column.clearwellhighleveldi = (type=bool and bring="[]") and
        column.clearwelllowleveldi = (type=bool and bring="[]") and
        column.generatoralarmdi = (type=bool and bring="[]") and
        column.generatorstatusdi = (type=bool and bring="[]") and
        column.oxygenmonitordi = (type=bool and bring="[]") and
        column.plantrunningdi = (type=bool and bring="[]") and
        column.plantstartdi = (type=bool and bring="[]") and
        column.servicepump1running_di = (type=bool and bring="[]") and
        column.servicepump2running_di = (type=bool and bring="[]") and
        column.plantshutdowndo = (type=bool and bring="[]") and
        column.watertowerlevelcommsdi = (type=bool and bring="[]") and
        column.plantenablechemicalsdo = (type=bool and bring="[]") and
        column.combinedchlorinatorvacdi = (type=bool and bring="[]") and
        column.freechlorinatorvacdi = (type=bool and bring="[]") and
        column.carbonfeeder_runningfwd = (type=bool and bring="[]")
    )>
        
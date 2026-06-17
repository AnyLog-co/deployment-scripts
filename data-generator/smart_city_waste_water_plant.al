#--------------------------------------------------------------------------------------------------------------#
# Hardcoded call to the data generator for waste water plant (wwp-analog + wwp-digital)
#
# :Sample Data (wwp-analog):
# {"AM_PDB1_FEEDBACK":35,"AM_PDB2_FEEDBACK":40,"AM_SludgePump_Rate":0,"AM_TA_DO_AI":0.26,
#  "HW_INFLUENT":441.27167,"timestamp":"2026-06-17T18:53:52.6726953Z", ...}
#
# :Sample Data (wwp-digital):
# {"SS_SCREENRUN_S":False,"AM_SEQ1A_VALVE":True,"AM_RASAB2_VALVE":False,
#  "timestamp":"2026-06-17T18:54:06.2992013Z", ...}
#--------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/smart_city_waste_water_plant.al

on error ignore

:msg-client:
on error goto msg-client-error

<run msg client where
    broker=172.104.228.251 and port=1883 and
    user=anyloguser and password=mqtt4AnyLog! and
    log=false and topic=(
        name=wwp-analog and
        dbms=!default_dbms and
        table=wwp_analog and
        column.timestamp.timestamp = "bring [timestamp]" and
        column.am_pdb1_feedback = (type=float and value="bring [AM_PDB1_FEEDBACK]") and
        column.am_pdb2_feedback = (type=float and value="bring [AM_PDB2_FEEDBACK]") and
        column.am_sludgepump_rate = (type=float and value="bring [AM_SludgePump_Rate]") and
        column.am_ta_do_ai = (type=float and value="bring [AM_TA_DO_AI]") and
        column.am_rasab2_on_display = (type=float and value="bring [AM_RASAB2_ON_DISPLAY]") and
        column.am_tb_do_ai = (type=float and value="bring [AM_TB_DO_AI]") and
        column.am_was1_pause_remain = (type=float and value="bring [AM_WAS1_PAUSE_REMAIN]") and
        column.am_was1_settle_remain = (type=float and value="bring [AM_WAS1_SETTLE_REMAIN]") and
        column.hw_influent = (type=float and value="bring [HW_INFLUENT]") and
        column.am_wasa_on_remain = (type=float and value="bring [AM_WASA_ON_REMAIN]") and
        column.am_wasb_on_remain = (type=float and value="bring [AM_WASB_ON_REMAIN]") and
        column.am_pdb1_status = (type=float and value="bring [AM_PDB1_STATUS]") and
        column.am_bp_rtm_hrs = (type=float and value="bring [AM_BP_RTM_HRS]") and
        column.am_pdb2_status = (type=float and value="bring [AM_PDB2_STATUS]") and
        column.am_pdb3_status = (type=float and value="bring [AM_PDB3_STATUS]") and
        column.am_pdb4_status = (type=float and value="bring [AM_PDB4_STATUS]") and
        column.am_ras1_off_time = (type=float and value="bring [AM_RAS1_OFF_TIME]") and
        column.uv_signal1_ai = (type=float and value="bring [UV_SIGNAL1_AI]") and
        column.hw_influent_ttlzr_curday = (type=float and value="bring [HW_INFLUENT_TTLZR_CurDay]") and
        column.hw_influent_ttlzr_yesday = (type=float and value="bring [HW_INFLUENT_TTLZR_YesDay]") and
        column.uv_room_temp_ai = (type=float and value="bring [UV_ROOM_TEMP_AI]") and
        column.am_rasab1_off_display = (type=float and value="bring [AM_RASAB1_OFF_DISPLAY]") and
        column.am_rasab1_on_display = (type=float and value="bring [AM_RASAB1_ON_DISPLAY]") and
        column.am_bp_rtm_mins = (type=float and value="bring [AM_BP_RTM_MINS]") and
        column.am_rasab2_off_display = (type=float and value="bring [AM_RASAB2_OFF_DISPLAY]") and
        column.am_was1_on_setpoint = (type=float and value="bring [AM_WAS1_ON_SETPOINT]") and
        column.am_was1_pause_setpoint = (type=float and value="bring [AM_WAS1_PAUSE_SETPOINT]") and
        column.am_was1_settle_setpoint = (type=float and value="bring [AM_WAS1_SETTLE_SETPOINT]") and
        column.am_pdb3_feedback = (type=float and value="bring [AM_PDB3_FEEDBACK]") and
        column.am_was1_start_hr = (type=float and value="bring [AM_WAS1_START_HR]") and
        column.am_was1_start_min = (type=float and value="bring [AM_WAS1_START_MIN]") and
        column.am_ras1_on_time = (type=float and value="bring [AM_RAS1_ON_TIME]") and
        column.am_seq1_off_total = (type=float and value="bring [AM_SEQ1_OFF_TOTAL]") and
        column.am_seq1_on_total = (type=float and value="bring [AM_SEQ1_ON_TOTAL]") and
        column.uv_signal2_ai = (type=float and value="bring [UV_SIGNAL2_AI]") and
        column.am_seq2_off_total = (type=float and value="bring [AM_SEQ2_OFF_TOTAL]") and
        column.am_seq2_on_total = (type=float and value="bring [AM_SEQ2_ON_TOTAL]") and
        column.am_seq1_off_setpoint = (type=float and value="bring [AM_SEQ1_OFF_SETPOINT]") and
        column.am_seq2_on_setpoint = (type=float and value="bring [AM_SEQ2_ON_SETPOINT]") and
        column.am_seq2_off_setpoint = (type=float and value="bring [AM_SEQ2_OFF_SETPOINT]") and
        column.am_seq1_on_setpoint = (type=float and value="bring [AM_SEQ1_ON_SETPOINT]") and
        column.am_hw_temp_ai = (type=float and value="bring [AM_HW_TEMP_AI]") and
        column.am_polymer_speed = (type=float and value="bring [AM_POLYMER_SPEED]") and
        column.am_pr_temp_ai = (type=float and value="bring [AM_PR_TEMP_AI]") and
        column.am_pdb4_feedback = (type=float and value="bring [AM_PDB4_FEEDBACK]") and
        column.am_sludgepress_daily = (type=float and value="bring [AM_SLUDGEPRESS_DAILY]")
    ) and topic=(
        name=wwp-digital and
        dbms=!default_dbms and
        table=wwp_digital and
        column.timestamp.timestamp = "bring [timestamp]" and
        column.ss_screenrun_s = (type=bool and value="bring [SS_SCREENRUN_S]") and
        column.ss_jam_a_alarm = (type=bool and value="bring [SS_JAM_A_Alarm]") and
        column.am_rasab2_valve = (type=bool and value="bring [AM_RASAB2_VALVE]") and
        column.uv_lf2_a_alarm = (type=bool and value="bring [UV_LF2_A_Alarm]") and
        column.am_was1_thr_pb = (type=bool and value="bring [AM_WAS1_THR_PB]") and
        column.am_seq1a_valve = (type=bool and value="bring [AM_SEQ1A_VALVE]") and
        column.am_seq1b_valve = (type=bool and value="bring [AM_SEQ1B_VALVE]") and
        column.am_seq2a_valve = (type=bool and value="bring [AM_SEQ2A_VALVE]") and
        column.mcc_brfrng_s = (type=bool and value="bring [MCC_BRFRNG_S]") and
        column.am_seq2b_valve = (type=bool and value="bring [AM_SEQ2B_VALVE]") and
        column.am_thickenera_alarm = (type=bool and value="bring [AM_ThickenerA_Alarm]") and
        column.am_thickenera_status = (type=bool and value="bring [AM_ThickenerA_Status]") and
        column.gk_shand_s = (type=bool and value="bring [GK_SHAND_S]") and
        column.am_thickenerb_alarm = (type=bool and value="bring [AM_ThickenerB_Alarm]") and
        column.uv_wf2_a_alarm = (type=bool and value="bring [UV_WF2_A_Alarm]") and
        column.am_thickenerb_status = (type=bool and value="bring [AM_ThickenerB_Status]") and
        column.am_was1_tue_pb = (type=bool and value="bring [AM_WAS1_TUE_PB]") and
        column.uv_gfd1_s_alarm = (type=bool and value="bring [UV_GFD1_S_Alarm]") and
        column.uv_gfd2_s_alarm = (type=bool and value="bring [UV_GFD2_S_Alarm]") and
        column.uv_cabht1_a_alarm = (type=bool and value="bring [UV_CABHT1_A_Alarm]") and
        column.uv_cabht2_a_alarm = (type=bool and value="bring [UV_CABHT2_A_Alarm]") and
        column.mcc_gen_a_alarm = (type=bool and value="bring [MCC_GEN_A_Alarm]") and
        column.am_airpress_notok = (type=bool and value="bring [AM_AirPress_NotOK]") and
        column.cg_a_in = (type=bool and value="bring [CG_A_IN]") and
        column.am_auger_alarm = (type=bool and value="bring [AM_Auger_Alarm]") and
        column.am_auger_status = (type=bool and value="bring [AM_Auger_Status]") and
        column.am_beltpress_alarm = (type=bool and value="bring [AM_BeltPress_Alarm]") and
        column.am_beltpress_status = (type=bool and value="bring [AM_BeltPress_Status]") and
        column.ss_hl_a_alarm = (type=bool and value="bring [SS_HL_A_Alarm]") and
        column.mcc_npwprng1_s = (type=bool and value="bring [MCC_NPWPRNG1_S]") and
        column.am_diga_valve = (type=bool and value="bring [AM_DIGA_VALVE]") and
        column.am_digb_valve = (type=bool and value="bring [AM_DIGB_VALVE]") and
        column.am_estop = (type=bool and value="bring [AM_ESTOP]") and
        column.am_hfla_valve = (type=bool and value="bring [AM_HFLA_VALVE]") and
        column.mcc_tstdbyrdy_s = (type=bool and value="bring [MCC_TSTDBYRDY_S]") and
        column.mcc_genrng_s = (type=bool and value="bring [MCC_GENRNG_S]") and
        column.am_hflb_valve = (type=bool and value="bring [AM_HFLB_VALVE]") and
        column.am_hvefrng_s = (type=bool and value="bring [AM_HVEFRNG_S]") and
        column.am_hvgas_a_in = (type=bool and value="bring [AM_HVGAS_A_IN]") and
        column.am_maindrum_alarm = (type=bool and value="bring [AM_MainDrum_Alarm]") and
        column.am_was1_wed_pb = (type=bool and value="bring [AM_WAS1_WED_PB]") and
        column.am_maindrum_status = (type=bool and value="bring [AM_MainDrum_Status]") and
        column.am_mx1_running = (type=bool and value="bring [AM_MX1_RUNNING]") and
        column.mcc_npwprng2_s = (type=bool and value="bring [MCC_NPWPRNG2_S]") and
        column.am_mx2_running = (type=bool and value="bring [AM_MX2_RUNNING]") and
        column.cg_fwdrev_s = (type=bool and value="bring [CG_FWDREV_S]") and
        column.am_polymer_alarm = (type=bool and value="bring [AM_Polymer_Alarm]") and
        column.am_polymer_status = (type=bool and value="bring [AM_Polymer_Status]") and
        column.am_was1_fri_pb = (type=bool and value="bring [AM_WAS1_FRI_PB]") and
        column.am_sludgepump_alarm = (type=bool and value="bring [AM_SludgePump_Alarm]") and
        column.am_sludgepump_status = (type=bool and value="bring [AM_SludgePump_Status]") and
        column.am_srg_ab_valve = (type=bool and value="bring [AM_SRG_AB_VALVE]") and
        column.gk_classrng_s = (type=bool and value="bring [GK_CLASSRNG_S]") and
        column.am_surge_high_alarm = (type=bool and value="bring [AM_SURGE_HIGH_ALARM]") and
        column.am_tanka_high_alarm = (type=bool and value="bring [AM_TANKA_HIGH_ALARM]") and
        column.am_tankb_high_alarm = (type=bool and value="bring [AM_TANKB_HIGH_ALARM]") and
        column.cg_start_s = (type=bool and value="bring [CG_START_S]") and
        column.am_wasa_valve = (type=bool and value="bring [AM_WASA_VALVE]") and
        column.mcc_srfrng_s = (type=bool and value="bring [MCC_SRFRNG_S]") and
        column.am_wasb_valve = (type=bool and value="bring [AM_WASB_VALVE]") and
        column.am_waterpump_alarm = (type=bool and value="bring [AM_WaterPump_Alarm]") and
        column.am_was1_mon_pb = (type=bool and value="bring [AM_WAS1_MON_PB]") and
        column.am_waterpump_status = (type=bool and value="bring [AM_WaterPump_Status]") and
        column.mcc_tsnprdy_s = (type=bool and value="bring [MCC_TSNPRDY_S]") and
        column.gk_fvo_s = (type=bool and value="bring [GK_FVO_S]") and
        column.mcc_tsstdby_s = (type=bool and value="bring [MCC_TSSTDBY_S]") and
        column.am_was1_sat_pb = (type=bool and value="bring [AM_WAS1_SAT_PB]") and
        column.uv_lf1_a_alarm = (type=bool and value="bring [UV_LF1_A_Alarm]") and
        column.am_was1_sun_pb = (type=bool and value="bring [AM_WAS1_SUN_PB]") and
        column.gk_gsf_s_in = (type=bool and value="bring [GK_GSF_S_IN]") and
        column.gk_pmprng_s = (type=bool and value="bring [GK_PMPRNG_S]") and
        column.ss_auto_s = (type=bool and value="bring [SS_AUTO_S]") and
        column.uv_wf1_a_alarm = (type=bool and value="bring [UV_WF1_A_Alarm]") and
        column.am_rasab1_valve = (type=bool and value="bring [AM_RASAB1_VALVE]")
    )>

get msg client

:msg-client-error:
echo "Failed to start MQTT client for waste water plant"

:end-script:
end script
set floorPlanUti 0.8

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win

# .global
set ::TimeLib::tsgMarkCellLatchConstructFlag 1
set conf_ioOri {R0}
set defHierChar {/}
set distributed_client_message_echo {1}
set distributed_mmmc_disable_reports_auto_redirection {0}
set eco_post_client_restore_command {update_timing ; write_eco_opt_db ;}
set enc_enable_print_mode_command_reset_options 1
set init_assign_buffer {1}
set init_gnd_net {VSS}
set init_import_mode { -keepEmptyModule 1 -treatUndefinedCellAsBbox 0}
set init_lef_file {../library/lef/tsmc13fsg_8lm_cic.lef ../library/lef/tpz013g3_8lm_cic.lef ../library/lef/RF2SH64x16.vclef ../library/lef/antenna_8.lef}
set init_mmmc_file {sw.view}
set init_pwr_net {VDD}
set init_top_cell {SmithWaterman}
set init_verilog {../syn/SmithWaterman_syn.v}
set latch_time_borrow_mode max_borrow
set pegDefaultResScaleFactor 1
set pegDetailResScaleFactor 1
set report_inactive_arcs_format {from to when arc_type sense reason}
set soft_stack_size_limit {80}
set tso_post_client_restore_command {update_timing ; write_eco_opt_db ;}

setMultiCpuUsage -localCpu max
setDistributeHost -local
init_design

# global nets
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo -inst *

# floorPlan
setIoFlowFlag 0
floorPlan -site TSM13SITE -r 1 $floorPlanUti 40 40 40 40
uiSetTool select
fit
###############################################################
#  Generated by:      Cadence Innovus 17.11-s080_1
#  OS:                Linux x86_64(Host ID cad29)
#  Generated on:      Sun Dec 29 15:25:11 2019
#  Design:            SmithWaterman
#  Command:           create_ccopt_clock_tree_spec -file ccopt.spec
###############################################################
#-------------------------------------------------------------------------------
# Clock tree setup script - dialect: Innovus
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

namespace eval ::ccopt {}
namespace eval ::ccopt::ilm {}
set ::ccopt::ilm::ccoptSpecRestoreData {}
# Start by checking for unflattened ILMs.
# Will flatten if so and then check the db sync.
if { [catch {ccopt_check_and_flatten_ilms_no_restore}] } {
  return -code error
}
# cache the value of the restore command output by the ILM flattening code
set ::ccopt::ilm::ccoptSpecRestoreData $::ccopt::ilm::ccoptRestoreILMState

# Clocks present at pin clk
#   clk (period 20.000ns) in timing_config func_mode([sw_apr.sdc])
#   clk (period 20.000ns) in timing_config scan_mode([sw_apr.sdc])
create_ccopt_clock_tree -name clk -source clk -no_skew_group
set_ccopt_property target_max_trans_sdc -delay_corner Delay_Corner_max -early -clock_tree clk 0.100

set_ccopt_property target_max_trans_sdc -delay_corner Delay_Corner_max -late -clock_tree clk 0.100
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_max -early -clock_tree clk 0.500
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_min -early -clock_tree clk 0.500
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_max -late -clock_tree clk 0.500
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_min -late -clock_tree clk 0.500
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_max -early -clock_tree clk 0.500
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_min -early -clock_tree clk 0.500
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_max -late -clock_tree clk 0.500
set_ccopt_property source_output_max_trans -delay_corner Delay_Corner_min -late -clock_tree clk 0.500
# Clock period setting for source pin of clk
set_ccopt_property clock_period -pin clk 20

# Skew group to balance non generated clock:clk in timing_config:func_mode (sdc sw_apr.sdc)
create_ccopt_skew_group -name clk/func_mode -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/func_mode true
set_ccopt_property target_insertion_delay -skew_group clk/func_mode 0.500
set_ccopt_property extracted_from_clock_name -skew_group clk/func_mode clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/func_mode func_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk/func_mode {Delay_Corner_max Delay_Corner_min}

# Skew group to balance non generated clock:clk in timing_config:scan_mode (sdc sw_apr.sdc)
create_ccopt_skew_group -name clk/scan_mode -sources clk -auto_sinks
set_ccopt_property include_source_latency -skew_group clk/scan_mode true
set_ccopt_property target_insertion_delay -skew_group clk/scan_mode 0.500
set_ccopt_property extracted_from_clock_name -skew_group clk/scan_mode clk
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk/scan_mode scan_mode
set_ccopt_property extracted_from_delay_corners -skew_group clk/scan_mode {Delay_Corner_max Delay_Corner_min}


check_ccopt_clock_tree_convergence
# Restore the ILM status if possible
if { [get_ccopt_property auto_design_state_for_ilms] == 0 } {
  if {$::ccopt::ilm::ccoptSpecRestoreData != {} } {
    eval $::ccopt::ilm::ccoptSpecRestoreData
  }
}


# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

# Add Tie High/Low Cell
setEndCapMode -reset
setEndCapMode -boundary_tap false
setUsefulSkewMode -maxSkew false -noBoundary false -useCells {BUFX12 BUFX16 BUFX2 BUFX20 BUFX3 BUFX4 BUFX6 BUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX2 CLKBUFX20 CLKBUFX3 CLKBUFX4 CLKBUFX6 CLKBUFX8 DLY1X1 DLY1X4 DLY2X1 DLY2X4 DLY3X1 DLY3X4 DLY4X1 DLY4X4 CLKINVX1 CLKINVX12 CLKINVX16 CLKINVX2 CLKINVX20 CLKINVX3 CLKINVX4 CLKINVX6 CLKINVX8 INVX1 INVX12 INVX16 INVX2 INVX20 INVX3 INVX4 INVX6 INVX8 INVXL} -maxAllowedDelay 1
setTieHiLoMode -reset
setTieHiLoMode -cell {  TIEHI TIELO } -maxDistance 100 -maxFanOut 10 -honorDontTouch false -createHierPort false
addTieHiLo -cell {TIEHI TIELO} -prefix LTIE


# set_ccopt_property.tcl
setOptMode -usefulSkewCCOpt standard

add_ndr -name CTS_2W1S -spacing {METAL1:METAL4 0.1 METAL5:METAL6 0.2 METAL7 0.3} -width {METAL1:METAL4 0.2 METAL5:METAL6 0.4 METAL7 0.6}
add_ndr -name CTS_2W2S -spacing {METAL1:METAL4 0.2 METAL5:METAL6 0.4 METAL7 0.6} -width {METAL1:METAL4 0.2 METAL5:METAL6 0.4 METAL7 0.6}

create_route_type -name leaf_rule -non_default_rule CTS_2W1S -top_preferred_layer METAL5 -bottom_preferred_layer METAL4
create_route_type -name trunk_rule -non_default_rule CTS_2W2S -top_preferred_layer METAL7 -bottom_preferred_layer METAL6 -shield_net VSS
#-bottom_shield_net METAL6
#create_route_type -name top_rule -non_default_rule CTS_2W2S -top_preferred_layer METAL9 -bottom_preferred_layer METAL8 -shield_net VSS
#-bottom_shield_net METAL8
set_ccopt_property -net_type leaf route_type leaf_rule
set_ccopt_property -net_type trunk route_type trunk_rule
#set_ccopt_property -net_type top route_type top_rule
set_ccopt_property routing_top_min_fanout 10000

set_ccopt_property buffer_cells {BUFX12 BUFX8 BUFX6 BUFX4 BUFX2}
set_ccopt_property inverter_cells {INVX12 INVX8 INVX6 INVX4 INVX2}
#set_ccopt_property clock_gating_cells {PREICGX12 PREICGX8 PREICGX6 IPREICGX4 PREICGX2}
set_ccopt_property use_inverters true
set_ccopt_property target_max_trans 100ps
set_ccopt_property target_skew 50ps


# ccopt 
create_ccopt_clock_tree_spec -file ccopt.spec
source ccopt.spec 
ccopt_design -cts

# timing report
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix SmithWaterman_postCTS -outDir timingReports
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_postCTS -outDir timingReports
set floorPlanUti 0.5

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_start_load.tcl
echo ==============================================

source sw.globals

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

init_design

# global nets
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo -inst *

# design mode
setDesignMode -process 130

# floorPlan
setIoFlowFlag 0
floorPlan -site TSM13SITE -r 1 $floorPlanUti 40 40 40 40
uiSetTool select
fit

# place standard cell
setPlaceMode -fp true
placeDesign -noPrePlaceOpt

# place standard cell
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setUsefulSkewMode -maxSkew false -noBoundary false -useCells {DLY4X4 DLY4X1 DLY3X4 DLY3X1 DLY2X4 DLY2X1 DLY1X4 DLY1X1 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX20 CLKBUFX2 CLKBUFX16 CLKBUFX12 BUFX8 BUFX6 BUFX4 BUFX3 BUFX20 BUFX2 BUFX16 BUFX12 INVXL INVX8 INVX6 INVX4 INVX3 INVX20 INVX2 INVX16 INVX12 INVX1 CLKINVX8 CLKINVX6 CLKINVX4 CLKINVX3 CLKINVX20 CLKINVX2 CLKINVX16 CLKINVX12 CLKINVX1} -maxAllowedDelay 1
setPlaceMode -fp false
placeDesign -noPrePlaceOpt

# Refine Placement
refinePlace -checkRoute 0 -preserveRouting 0 -rmAffectedRouting 0 -swapEEQ 0

#Timing Report
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_preCTS -outDir timingReports

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_finish_load.tcl
echo ==============================================

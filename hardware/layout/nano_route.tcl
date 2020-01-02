echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_start_nano_route.tcl
echo ==============================================


# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

# Nano Route
# setNanoRouteMode -quiet -routeInsertAntennaDiode 1
# setNanoRouteMode -quiet -routeAntennaCellName ANTENNA

setNanoRouteMode -drouteFixAntenna false
setNanoRouteMode -routeAntennaCellName "ANTENNA"
setNanoRouteMode -routeInsertAntennaDiode false

setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

setAnalysisMode -analysisType onChipVariation

# Timing Report
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir timingReports
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir timingReports

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_finish_nano_route.tcl
echo ==============================================

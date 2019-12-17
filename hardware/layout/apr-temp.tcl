restoreDesign aprv04_2.6ns_0.4/nano_route-post-eco.dat SmithWaterman

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

# eco
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postRoute
optDesign -postRoute -hold
# nano_route post-eco
saveDesign autosave-temp/nano_route-post-eco
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir timingReports > autosave-temp/nano_route-post-eco-setup.log
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir timingReports > autosave-temp/nano_route-post-eco-hold.log
# verify
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry > autosave-temp/nano_route-verify.log
setVerifyGeometryMode -area { 0 0 0 0 }

exit
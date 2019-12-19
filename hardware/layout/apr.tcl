source load.tcl
# placement pre-eco Pre-cts
saveDesign autosave/placement-pre-eco
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_preCTS -outDir autosave > autosave/placement-pre-eco.log
# placement eco
source eco-prects.tcl
# placement post-eco Pre-cts
saveDesign autosave/placement-post-eco
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_preCTS -outDir autosave > autosave/placement-post-eco.log

source power.tcl
# power verify
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry > autosave/power-verify.log
setVerifyGeometryMode -area { 0 0 0 0 }
# power pre-eco Pre-cts
saveDesign autosave/power-pre-eco
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_preCTS -outDir autosave > autosave/power-pre-eco.log
# power eco
source eco-prects.tcl
# power post-eco Pre-cts
saveDesign autosave/power-post-eco
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_preCTS -outDir autosave > autosave/power-post-eco.log

source cts.tcl
# cts pre-eco post-cts
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix SmithWaterman_postCTS -outDir autosave > autosave/cts-pre-eco-hold.log
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_postCTS -outDir autosave >  autosave/cts-pre-eco-setup.log
saveDesign autosave/cts-pre-eco
# cts eco
source eco-postcts.tcl
# cts post-eco post-cts
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix SmithWaterman_postCTS -outDir autosave > autosave/cts-post-eco-hold.log
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_postCTS -outDir autosave >  autosave/cts-post-eco-setup.log
saveDesign autosave/cts-post-eco

source special_route.tcl
# sprcial route verify
verifyConnectivity -type special -noUnroutedNet -error 1000 -warning 50 > autosave/special_route-verify.log

source nano_route.tcl
# nano_route pre-eco
saveDesign autosave/nano_route-pre-eco
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir autosave > autosave/nano_route-pre-eco-setup.log
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir autosave > autosave/nano_route-pre-eco-hold.log
# eco
source eco-postroute.tcl
# nano_route post-eco
saveDesign autosave/nano_route-post-eco
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir autosave > autosave/nano_route-post-eco-setup.log
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix SmithWaterman_postRoute -outDir autosave > autosave/nano_route-post-eco-hold.log
# verify
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry > autosave/nano_route-verify.log
setVerifyGeometryMode -area { 0 0 0 0 }

exit

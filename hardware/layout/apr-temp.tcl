restoreDesign autosave/nano_route-post-eco.dat SmithWaterman

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

# output
saveNetlist SmithWaterman_apr.v
all_hold_analysis_views
all_setup_analysis_views
write_sdf SmithWaterman_apr.sdf
setStreamOutMode -specifyViaName default -SEvianames false -virtualConnection false -uniquifyCellNamesPrefix false -snapToMGrid false -textSize 1 -version 3
streamOut SmithWaterman_apr.gds -mapFile ../library/streamOut.map -libName DesignLib -merge { ../library/gds/tpz013g3_v1.1.gds ../library/gds/tsmc13gfsg_fram.gds } -outputMacros -units 1000 -mode ALL

exit

setPlaceMode -fp true
placeDesign -noPrePlaceOpt
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setUsefulSkewMode -maxSkew false -noBoundary false -useCells {DLY4X4 DLY4X1 DLY3X4 DLY3X1 DLY2X4 DLY2X1 DLY1X4 DLY1X1 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX20 CLKBUFX2 CLKBUFX16 CLKBUFX12 BUFX8 BUFX6 BUFX4 BUFX3 BUFX20 BUFX2 BUFX16 BUFX12 INVXL INVX8 INVX6 INVX4 INVX3 INVX20 INVX2 INVX16 INVX12 INVX1 CLKINVX8 CLKINVX6 CLKINVX4 CLKINVX3 CLKINVX20 CLKINVX2 CLKINVX16 CLKINVX12 CLKINVX1} -maxAllowedDelay 1
setPlaceMode -fp false
placeDesign -noPrePlaceOpt
refinePlace -checkRoute 0 -preserveRouting 0 -rmAffectedRouting 0 -swapEEQ 0
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -prePlace -pathReports -drvReports -slackReports -numPaths 50 -prefix SmithWaterman_prePlace -outDir timingReports
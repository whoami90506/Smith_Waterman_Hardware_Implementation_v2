echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_start_special_route.tcl
echo ==============================================


# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

# Special Route
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { corePin } -layerChangeRange { METAL1(1) METAL8(8) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { METAL1(1) METAL8(8) } -nets { VSS VDD } -allowLayerChange 1 -targetViaLayerRange { METAL1(1) METAL8(8) }

# Refine Placement
refinePlace -checkRoute 0 -preserveRouting 0 -rmAffectedRouting 0 -swapEEQ 0

# verify Connectivity
verifyConnectivity -type special -noUnroutedNet -error 1000 -warning 50

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_finish_special_route.tcl
echo ==============================================

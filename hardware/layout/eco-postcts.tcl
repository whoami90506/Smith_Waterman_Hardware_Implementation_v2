echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_start_eco-postcts.tcl
echo ==============================================


# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
optDesign -postCTS -hold

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_finish_eco-postcts.tcl
echo ==============================================

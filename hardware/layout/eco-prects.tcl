echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_start_eco-prects.tcl
echo ==============================================

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_eco1
echo ==============================================

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_eco2
echo ==============================================

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_eco3
echo ==============================================

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_eco4
echo ==============================================

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_finish_eco-prects.tcl
echo ==============================================

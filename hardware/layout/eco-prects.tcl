echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_start_eco-prects.tcl
echo ==============================================

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS

# save 
saveDesign autosave/eco_prects

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_finish_eco-prects.tcl
echo ==============================================

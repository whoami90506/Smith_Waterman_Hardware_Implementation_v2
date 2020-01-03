echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_start_eco-postroute.tcl
echo ==============================================

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postRoute
optDesign -postRoute -hold
optDesign -postRoute -hold
optDesign -postRoute -hold
optDesign -postRoute -hold
optDesign -postRoute -hold
optDesign -postRoute -hold

echo ==============================================
date +%m/%d_%A_%H:%M:%S_Mylog_finish_eco-postroute.tcl
echo ==============================================

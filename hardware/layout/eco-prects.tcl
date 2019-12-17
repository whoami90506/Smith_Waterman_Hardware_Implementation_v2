echo ==============================================
echo   Mylog start eco-prects.tcl
echo ==============================================

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS

# save 
saveDesign autosave/eco_prects

echo ==============================================
echo   Mylog finish eco-prects.tcl
echo ==============================================
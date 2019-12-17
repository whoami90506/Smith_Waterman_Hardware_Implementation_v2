echo ==============================================
echo   Mylog start eco-postcts.tcl
echo ==============================================


# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
optDesign -postCTS -hold

# save 
saveDesign autosave/eco_postcts

echo ==============================================
echo   Mylog finish eco-postcts.tcl
echo ==============================================

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS
optDesign -postCTS -hold

# save 
saveDesign autosave/eco_postcts
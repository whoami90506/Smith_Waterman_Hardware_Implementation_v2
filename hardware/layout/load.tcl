set floorPlanUti 0.8

source sw.globals

# set numCPU
setMultiCpuUsage -localCpu max
setDistributeHost -local

init_design

# global nets
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo -inst *

# floorPlan
setIoFlowFlag 0
floorPlan -site TSM13SITE -r 1 $floorPlanUti 40 40 40 40
uiSetTool select
fit
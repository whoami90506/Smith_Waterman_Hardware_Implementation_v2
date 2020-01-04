echo ============================================ | tee    syn/syn.log
date '+%m/%d %A %H:%M:%S Mylog start dc_shell'    | tee -a syn/syn.log
echo ============================================ | tee -a syn/syn.log
dc_shell -f syn/sw.tcl 2>&1                       | tee -a syn/syn.log

echo ============================================ | tee -a syn/syn.log
date '+%m/%d %A %H:%M:%S Mylog finish dc_shell'   | tee -a syn/syn.log
echo ============================================ | tee -a syn/syn.log

exit

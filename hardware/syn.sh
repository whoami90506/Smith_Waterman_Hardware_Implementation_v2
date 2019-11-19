echo ============================================ | tee syn/syn.log
date '+%m/%d %A %H:%M:%S' | tee -a syn/syn.log
echo start dc_shell | tee -a syn/syn.log
echo ============================================ | tee -a syn/syn.log
dc_shell -f syn/sw.tcl | tee -a syn/syn.log

echo ============================================ | tee -a syn/syn.log
date '+%m/%d %A %H:%M:%S' | tee -a syn/syn.log
echo finish dc_shell | tee -a syn/syn.log
echo ============================================ | tee -a syn/syn.log

exit

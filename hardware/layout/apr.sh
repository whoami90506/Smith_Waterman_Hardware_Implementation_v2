echo ============================================ | tee apr.log
date '+%m/%d %A %H:%M:%S' | tee -a apr.log
echo start innovus | tee -a apr.log
echo ============================================ | tee -a apr.log
innovus -files apr.tcl -no_gui | tee -a apr.log

echo ============================================ | tee -a apr.log
date '+%m/%d %A %H:%M:%S' | tee -a apr.log
echo finish innovus | tee -a apr.log
echo ============================================ | tee -a apr.log

exit
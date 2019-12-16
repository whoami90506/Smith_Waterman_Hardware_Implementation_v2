echo ============================================ | tee apr-temp.log
date '+%m/%d %A %H:%M:%S' | tee -a apr-temp.log
echo start innovus | tee -a apr-temp.log
echo ============================================ | tee -a apr-temp.log
innovus -files apr-temp.tcl -no_gui | tee -a apr-temp.log

echo ============================================ | tee -a apr-temp.log
date '+%m/%d %A %H:%M:%S' | tee -a apr-temp.log
echo finish innovus | tee -a apr-temp.log
echo ============================================ | tee -a apr-temp.log

exit
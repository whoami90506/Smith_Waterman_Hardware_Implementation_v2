echo ============================================ | tee autoreport/apr.log
date '+%m/%d %A %H:%M:%S' | tee -a autoreport/apr.log
echo start innovus | tee -a autoreport/apr.log
echo ============================================ | tee -a autoreport/apr.log
innovus -files apr.tcl -no_gui | tee -a autoreport/apr.log

echo ============================================ | tee -a autoreport/apr.log
date '+%m/%d %A %H:%M:%S' | tee -a autoreport/apr.log
echo finish innovus | tee -a autoreport/apr.log
echo ============================================ | tee -a autoreport/apr.log

exit
echo ============================================ | tee autosave/apr.log
date '+%m/%d %A %H:%M:%S' | tee -a autosave/apr.log
echo start innovus | tee -a autosave/apr.log
echo ============================================ | tee -a autosave/apr.log
innovus -files apr.tcl -no_gui | tee -a autosave/apr.log

echo ============================================ | tee -a autosave/apr.log
date '+%m/%d %A %H:%M:%S' | tee -a autosave/apr.log
echo finish innovus | tee -a autosave/apr.log
echo ============================================ | tee -a autosave/apr.log

exit
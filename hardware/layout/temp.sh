echo ============================================ | tee apr-temp.log
date '+%m/%d %A %H:%M:%S Mylog start innovus'     | tee -a apr.log
echo ============================================ | tee -a apr-temp.log
innovus -files apr-temp.tcl -no_gui               | tee -a apr-temp.log

echo ============================================ | tee -a apr-temp.log
date '+%m/%d %A %H:%M:%S Mylog finish innovus'    | tee -a apr.log
echo ============================================ | tee -a apr-temp.log

mv apr-temp.log autosave/

exit
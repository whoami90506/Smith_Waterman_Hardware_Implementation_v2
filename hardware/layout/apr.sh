echo ============================================ | tee apr.log
date '+%m/%d %A %H:%M:%S Mylog start innovus'     | tee -a apr.log
echo ============================================ | tee -a apr.log
sed -e '/set_clock_latency*/d' sw_apr.sdc > sw_apr_cts.sdc
innovus -files apr.tcl -no_gui       2>&1         | tee -a apr.log

echo ============================================ | tee -a apr.log
date '+%m/%d %A %H:%M:%S Mylog finish innovus'    | tee -a apr.log
echo ============================================ | tee -a apr.log

mv apr.log autosave/
exit
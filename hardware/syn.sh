date '+%m/%d %A %H:%M:%S'
echo start dc_shell

dc_shell -f syn/sw.tcl | tee syn/syn.log

date '+%m/%d %A %H:%M:%S'
echo finish dc_shell

exit

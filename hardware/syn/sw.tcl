# Import Design
read_file -format verilog  src/smithWaterman.v
read_file -format verilog  src/buffer.v
read_file -format verilog  src/loader.v
read_file -format verilog  src/parserOut.v
read_file -format verilog  src/parserQ.v
read_file -format verilog  src/parserT.v
read_file -format verilog  src/PE.v

current_design [get_designs SmithWaterman]
link

source -echo -verbose ./syn/sw.sdc

# Compile Design
current_design [get_designs SmithWaterman]

set high_fanout_net_threshold 0

uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

check_design > syn/report.check_design
# compile -power_effort none
compile_ultra

# Output Design
current_design [get_designs SmithWaterman]

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]

set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

write -format ddc     -hierarchy -output "syn/SmithWaterman_syn.ddc"
write -format verilog -hierarchy -output "syn/SmithWaterman_syn.v"
write_sdf -version 2.1 -context verilog syn/SmithWaterman_syn.sdf

report_timing > syn/report.timing
report_area > syn/report.area
report_power > syn/report.power
report_timing

quit
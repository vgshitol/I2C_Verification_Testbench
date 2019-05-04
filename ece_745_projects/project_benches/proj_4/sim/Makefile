export ECE745_PROJECT_HOME ?= $(PWD)/../../..
export ECE745_COMMON_HOME ?= $(PWD)/../../../../../common/project_2_provided_files
GEN_TRANS_TYPE ?= wb_transaction
TEST_SEED ?= 123

include $(ECE745_COMMON_HOME)/ncsu_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
GEN_TRANS_TYPE ?= wb_transaction

clean: 
	rm -rf work *.wlf transcript
	rm -f *.ucdb
	rm -rf covhtmlreport


comp_I2C_MB:
	vcom -cover sbcefx ../rtl/iicmb_int_pkg.vhd
	vcom -cover sbcefx ../rtl/iicmb_pkg.vhd
	vcom -cover sbcefx ../rtl/mbyte.vhd
	vcom -cover sbcefx ../rtl/mbit.vhd
	vcom -cover sbcefx ../rtl/bus_state.vhd
	vcom -cover sbcefx ../rtl/filter.vhd
	vcom -cover sbcefx ../rtl/conditioner.vhd
	vcom -cover sbcefx ../rtl/conditioner_mux.vhd
	vcom -cover sbcefx ../rtl/iicmb_m.vhd
	vcom -cover sbcefx ../rtl/regblock.vhd
	vcom -cover sbcefx ../rtl/wishbone.vhd
	vcom -cover sbcefx ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg 
	vlog ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -coverage -sv_seed $(TEST_SEED) -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do ;" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

debug: clean compile simulate

run_cli:
	vsim  -coverage -c -sv_seed $(TEST_SEED) -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

run_gui:
	vsim  -coverage -sv_seed $(TEST_SEED) -i -classdebug -msgmode both -do "set NoQuitOnFinish 1;do wave.do;run -a;add testbrowser ./*.ucdb;coverage open ./sim_and_testplan_merged.ucdb" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: compile run_cli

convert_testplan:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	add testbrowser ./*.ucdb

merge_coverage:
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb

custom_debug: clean convert_testplan cli merge_coverage report_coverage run_gui

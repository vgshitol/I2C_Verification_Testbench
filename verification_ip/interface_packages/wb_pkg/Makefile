export ECE745_PROJECT_HOME ?= $(PWD)/../../..
export ECE745_COMMON_HOME ?= $(PWD)/../../../../../common/project_2_provided_files

comp_wb_pkg:

	vlog +incdir+$(ECE745_COMMON_HOME)/ncsu_pkg $(ECE745_COMMON_HOME)/ncsu_pkg/ncsu_pkg.sv
	vlog $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/src/wb_if.sv
	vlog +incdir+$(ECE745_COMMON_HOME)/ncsu_pkg $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/wb_pkg.sv

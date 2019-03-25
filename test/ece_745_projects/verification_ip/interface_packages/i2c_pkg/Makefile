export ECE745_PROJECT_HOME ?= $(PWD)/../../..
export ECE745_COMMON_HOME ?= $(PWD)/../../../../../common/project_2_provided_files

comp_i2c_pkg:
	vlog +incdir+$(ECE745_COMMON_HOME)/ncsu_pkg $(ECE745_COMMON_HOME)/ncsu_pkg/ncsu_pkg.sv
	vlog +incdir+$(ECE745_COMMON_HOME)/ncsu_pkg $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/i2c_pkg.sv
	vlog $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/src/i2c_if.sv

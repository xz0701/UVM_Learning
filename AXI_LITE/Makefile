SHELL    = /bin/bash
VCS      = vcs
SIM_DIR  = sim
FLIST    = ../script/filelist.f
TOP      = tb_top
ENV_SETUP ?= ../../env/setup.sh
WIDTH ?= 8
DEPTH ?= 16
WR_CLK_PERIOD ?= 10
RD_CLK_PERIOD ?= 16
TEST  ?= axi_lite_test

ifeq ($(TEST),axi_lite_demux_smoke_test)
TOP = tb_demux_top
endif

ifeq ($(TEST),axi_lite_read_only_test)
VCS_TEST_DEFINES = +define+AXI_LITE_READ_ONLY_TEST
endif

ifeq ($(TEST),axi_lite_prot_test)
VCS_TEST_DEFINES += +define+AXI_LITE_PROT_TEST
endif

VCS_OPTS = -full64 \
           -sverilog \
           -ntb_opts uvm \
           $(VCS_TEST_DEFINES) \
           +define+WIDTH=$(WIDTH) \
           +define+DEPTH=$(DEPTH) \
           +define+WR_CLK_PERIOD=$(WR_CLK_PERIOD) \
           +define+RD_CLK_PERIOD=$(RD_CLK_PERIOD) \
           -timescale=1ns/1ps \
           -debug_access+all \
           -top $(TOP) \
           -l compile.log

SIM_OPTS = +UVM_TESTNAME=$(TEST) \
           -l run.log

LOAD_ENV = if [[ -f "$(ENV_SETUP)" ]]; then source "$(ENV_SETUP)"; fi

all: run

$(SIM_DIR):
	mkdir -p $(SIM_DIR)

compile: $(SIM_DIR)
	$(LOAD_ENV); cd $(SIM_DIR) && $(VCS) $(VCS_OPTS) -f $(FLIST) -o simv

run: compile
	$(LOAD_ENV); cd $(SIM_DIR) && ./simv $(SIM_OPTS)

regression:
	./script/run_regression.sh

clean:
	rm -rf $(SIM_DIR)/simv \
	       $(SIM_DIR)/simv.daidir \
	       $(SIM_DIR)/csrc \
	       $(SIM_DIR)/*.log \
	       $(SIM_DIR)/*.vpd \
	       $(SIM_DIR)/*.fsdb \
	       $(SIM_DIR)/ucli.key \
	       $(SIM_DIR)/DVEfiles \
	       $(SIM_DIR)/inter.vpd \
		   $(SIM_DIR)/regression_logs

.PHONY: all compile run regression clean

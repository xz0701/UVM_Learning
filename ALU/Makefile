VCS      = vcs
SIM_DIR  = sim
FLIST    = ../script/filelist.f
TOP      = tb_top
TEST     = alu_test

VCS_OPTS = -full64 \
           -sverilog \
           -ntb_opts uvm \
           -timescale=1ns/1ps \
           -debug_access+all \
           -top $(TOP) \
           -l compile.log

SIM_OPTS = +UVM_TESTNAME=$(TEST) \
           -l run.log

all: run

$(SIM_DIR):
	mkdir -p $(SIM_DIR)

compile: $(SIM_DIR)
	cd $(SIM_DIR) && $(VCS) $(VCS_OPTS) -f $(FLIST) -o simv

run: compile
	cd $(SIM_DIR) && ./simv $(SIM_OPTS)

clean:
	rm -rf $(SIM_DIR)/simv \
	       $(SIM_DIR)/simv.daidir \
	       $(SIM_DIR)/csrc \
	       $(SIM_DIR)/*.log \
	       $(SIM_DIR)/*.vpd \
	       $(SIM_DIR)/*.fsdb \
	       $(SIM_DIR)/ucli.key \
	       $(SIM_DIR)/DVEfiles \
	       $(SIM_DIR)/inter.vpd

.PHONY: all compile run clean
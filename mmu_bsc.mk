BENDER ?= bender

VLOG_ARGS ?= -suppress 2583 -suppress 13314
VSIM      ?= vsim

# Define used paths (prefixed to avoid name conflicts)
BRK_ROOT      ?= $(shell $(BENDER) path mmu)

################
# Dependencies #
################

BENDER_ROOT ?= $(BRK_ROOT)/.bender

# Ensure both Bender dependencies and (essential) submodules are checked out
$(BENDER_ROOT)/.brk_deps:
	$(BENDER) checkout
ifneq ($(wildcard $@),)
	@touch $@
else
	@echo "$@ Doesn't exist"
endif

# Make sure dependencies are more up-to-date than any targets run
ifeq ($(shell test -f $(BENDER_ROOT)/.brk_deps && echo 1),)
-include $(BENDER_ROOT)/.brk_deps
endif

# Running this target will reset dependencies (without updating the checked-in Bender.lock)
brk-clean-deps:
	rm -rf .bender


##############
# Simulation #
##############

$(BRK_ROOT)/target/sim/vsim/compile.mmu.tcl: Bender.yml
	$(BENDER) script vsim -t sim -t test -t rtl --vlog-arg="$(VLOG_ARGS)" > $@
	echo 'vlog "$(realpath $(BRK_ROOT))/target/sim/src/elfloader.cpp" -ccflags "-std=c++11"' >> $@

BRK_SIM_ALL += $(BRK_ROOT)/target/sim/vsim/compile.mmu.tcl

clean_sim:
	rm -rf $(BRK_ROOT)/target/sim/vsim/compile.mmu.tcl

run_sim:
	$(VSIM) -c -do $(BRK_ROOT)/target/sim/vsim/run.do
	

#################################
# Phonies (KEEP AT END OF FILE) #
#################################

.PHONY: brk-all brk-clean-deps brk-hw-all brk-sim-all

BRK_ALL += $(BRK_HW_ALL) $(BRK_SIM_ALL) $(BRK_XILINX_ALL)

brk-all:         $(BRK_ALL)
brk-sw-all:      $(BRK_SW_ALL)
brk-hw-all:      $(BRK_HW_ALL)
brk-sim-all:     $(BRK_SIM_ALL)
clean: clean_sim

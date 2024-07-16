BRK_ROOT ?= $(shell pwd)
BENDER	 ?= bender -d $(BRK_ROOT)

include mmu_bsc.mk

all:
	@$(MAKE) brk-all

%-all:
	@$(MAKE) brk-$*-all

clean-%:
	@$(MAKE) brk-clean-$*

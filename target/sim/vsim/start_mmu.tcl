set TESTBENCH mmu_tb

# Set voptargs only if not already set to make overridable.
# Default on fast simulation flags.
if {![info exists VOPTARGS]} {
    set VOPTARGS "+acc"
}

set flags "-permissive -suppress 3009 -suppress 8386 -error 7 "
if {[info exists SELCFG]} { append flags "-GSelectedCfg=${SELCFG} " }

set pargs ""
if {[info exists BOOTMODE]} { append pargs "+BOOTMODE=${BOOTMODE} " }
if {[info exists BINARY]}   { append pargs "+BINARY=${BINARY} " }

eval "vsim -c ${TESTBENCH} -t 1ps -vopt -voptargs=\"${VOPTARGS}\" -do wave.do" ${pargs} ${flags}

set StdArithNoWarnings 1
set NumericStdNoWarnings 1


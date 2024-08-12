//-----------------------------
// includes
//-----------------------------

`timescale 1 ns / 1 ns
//`default_nettype none

module mmu_tb();
import mmu_pkg::*;
//-----------------------------
// Local parameters
//-----------------------------
    parameter VERBOSE         = 1;
    parameter CLK_PERIOD      = 2;
    parameter CLK_HALF_PERIOD = CLK_PERIOD / 2;

//-----------------------------
// Signals
//-----------------------------
  reg     tb_clk_i;
  reg     tb_rstn_i;
    
  cache_tlb_comm_t tb_icache_itlb_comm_i;
  tlb_cache_comm_t tb_itlb_icache_comm_o;
  cache_tlb_comm_t tb_core_dtlb_comm_i;
  tlb_cache_comm_t tb_dtlb_core_comm_o;
  dmem_ptw_comm_t tb_dmem_ptw_comm_i;
  ptw_dmem_comm_t tb_ptw_dmem_comm_o;

  csr_ptw_comm_t tb_csr_ptw_comm_i;

//-----------------------------
// Module
//-----------------------------

mmu_top DUT_MMU
(
    .clk_i(tb_clk_i),
    .rstn_i(tb_rstn_i),

    //-------------- TLB --------------
    // iTLB request-response
    .icache_itlb_comm_i(tb_icache_itlb_comm_i),   // Communication from translation requester to iTLB.
    .itlb_icache_comm_o(tb_itlb_icache_comm_o),   // Communication from iTLB to translation requester.

    // dTLB request-response
    .core_dtlb_comm_i(tb_core_dtlb_comm_i),   // Communication from translation requester to dTLB.
    .dtlb_core_comm_o(tb_dtlb_core_comm_o),   // Communication from dTLB to translation requester.

    // PMU counter events
    .pmu_itlb_access_o(),              // Accepted Translation request to iTLB. 
    .pmu_itlb_miss_o(),                // Accepted Translation request to iTLB misses. 
    .pmu_dtlb_access_o(),              // Accepted Translation request to dTLB. 
    .pmu_dtlb_miss_o(),                // Accepted Translation request to dTLB misses. 

    //-------------- PTW --------------
    // dmem request-response
    .dmem_ptw_comm_i(tb_dmem_ptw_comm_i),
    .ptw_dmem_comm_o(tb_ptw_dmem_comm_o),

    // csr interface
    .csr_ptw_comm_i(tb_csr_ptw_comm_i),

    // pmu interface
    .pmu_ptw_hit_o(),
    .pmu_ptw_miss_o()
);

always_ff @(posedge tb_clk_i, negedge tb_rstn_i) begin
  if(~tb_rstn_i) begin
    tb_dmem_ptw_comm_i            = '0;
    tb_dmem_ptw_comm_i.dmem_ready = 1'b1;
  end else begin
    if(tb_dmem_ptw_comm_i.resp.valid) begin
      tb_dmem_ptw_comm_i.dmem_ready = 1'b1;
      tb_dmem_ptw_comm_i.resp.valid = 1'b0;
    end

    if(~tb_dmem_ptw_comm_i.dmem_ready) begin
      tb_dmem_ptw_comm_i.resp.valid = 1'b1;
      case (tb_ptw_dmem_comm_o.req.addr)
        42'h0080004FF8: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h20001801;
        end
        42'h0080006FF8: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h200000CF;
        end
        42'h0080004080: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h20001431;
        end
        42'h0080004088: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h20002031;
        end
        42'h0080004090: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h300000F7;//64'h20002C31;
        end
        42'h0080004098: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h20003831;
        end
        42'h00800050A0: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h20001831;
        end
        42'h0080006100: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h20001CF7;
        end
        42'h0080007080: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h110E88831;
        end
        42'h00800080E8: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h228000F7;//64'h20002431;
        end
        //42'h0080009110: begin
        //  tb_dmem_ptw_comm_i.resp.data = 64'h200028F7;
        //end
        42'h008A0220A8: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h121288C31;
        end
        //42'h008000B128: begin
        //  tb_dmem_ptw_comm_i.resp.data = 64'h20003031;
        //end
        //42'h008000C118: begin
        //  tb_dmem_ptw_comm_i.resp.data = 64'h200034F7;
        //end
        42'h00C4A23108: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h1316890F7;
        end
        42'h008000E168: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h20003C31;
        end
        42'h008000F120: begin
          tb_dmem_ptw_comm_i.resp.data = 64'h2003FCF7;
        end
        default: begin
          tb_dmem_ptw_comm_i.resp.data = '0;
        end
      endcase
    end
    
    if(tb_ptw_dmem_comm_o.req.valid) begin
      tb_dmem_ptw_comm_i.dmem_ready = 1'b0;
    end
  end
end

//-----------------------------
// DUT
//-----------------------------


    //***clk_gen***
    // A single clock source is used in this design.
    initial tb_clk_i = 1;
    always #CLK_HALF_PERIOD tb_clk_i = !tb_clk_i;

    //***task automatic reset_dut***
    task automatic reset_dut;
        begin
            $display("*** Toggle reset.");
            tb_rstn_i <= 1'b0;
            tb_icache_itlb_comm_i = '0;
            tb_icache_itlb_comm_i.req.instruction = 1'b1;
            tb_core_dtlb_comm_i = '0;
            //tb_dmem_ptw_comm_i = '0;
            tb_csr_ptw_comm_i = '0;
            tb_csr_ptw_comm_i.satp = 64'h80004;
            tb_csr_ptw_comm_i.vsatp = 64'h402820;
            tb_csr_ptw_comm_i.hgatp = 64'h80004;
            tb_csr_ptw_comm_i.mstatus.fs = 2'b11;
            tb_csr_ptw_comm_i.mstatus.sd = 1'b1;
            tb_csr_ptw_comm_i.mstatus.sxl = 2'b10;
            tb_csr_ptw_comm_i.mstatus.uxl = 2'b10;
            tb_csr_ptw_comm_i.mstatus.zero3 = 2'b11;

            #CLK_PERIOD;
            tb_rstn_i <= 1'b1;
            //#CLK_PERIOD;
            $display("Done");
        end
    endtask

    //***task automatic init_sim***
    task automatic init_sim;
        begin
            $display("*** init_sim");
            tb_clk_i <='{default:1};
            tb_rstn_i<='{default:0};
            $display("Done");
        end
    endtask

    //***task automatic init_dump***
    //This task dumps the ALL signals of ALL levels of instance dut_example into the test.vcd file
    //If you want a subset to modify the parameters of $dumpvars
    task automatic init_dump;
        begin
            $display("*** init_dump");
            $dumpfile("dump_file.vcd");
            $dumpvars(0,DUT_MMU);
        end
    endtask

    task automatic tick();
        begin
            //$display("*** tick");
            #CLK_PERIOD;
        end
    endtask

//***task automatic test_sim***
    task automatic test_sim;
        begin
            int tmp;
            $display("*** test_sim");
            // check req valid 0
            test_itlb(tmp);
            //test_dcache(tmp);
            if (tmp == 1) begin
                //`START_RED_PRINT
                        $display("TEST FAILED");
                //`END_COLOR_PRINT
            end else begin
                //`START_GREEN_PRINT
                        $display("ALL TEST PASSED");
                //`END_COLOR_PRINT
            end
        end
    endtask

    task automatic test_itlb;
        output int tmp;
        begin
            tmp = 0;
            tick();
            $display("*** test_itlb");
            tb_icache_itlb_comm_i.priv_lvl = 2'b01;
            tick();
            tb_icache_itlb_comm_i.req.vpn = 27'h80001;
            $display("Testing with vpn %x (vm disabled)", tb_icache_itlb_comm_i.req.vpn);
            tb_icache_itlb_comm_i.req.valid = 1'b1;
            tick();
            tb_icache_itlb_comm_i.req.valid = 1'b0;
            tick();
            wait(tb_itlb_icache_comm_o.tlb_ready);
            $display("result itlb: %x", tb_itlb_icache_comm_o.resp.ppn);
            tick();
            $display("*** test_itlb_ptw");
            tb_icache_itlb_comm_i.vm_enable = 1'b1;
            tb_icache_itlb_comm_i.req.vpn = 27'hFFFFE00;
            $display("Testing with vpn %x (vm enabled)", tb_icache_itlb_comm_i.req.vpn);
            tb_icache_itlb_comm_i.req.valid = 1'b1;
            tick();
            tb_icache_itlb_comm_i.req.valid = 1'b0;
            tick();
            wait(tb_itlb_icache_comm_o.tlb_ready);
            $display("result itlb + ptw: %x", tb_itlb_icache_comm_o.resp.ppn);
            tick();
            $display("*** test_itlb_ptw virtualized environment");
            tb_icache_itlb_comm_i.vs_enable = 1'b1;
            tb_icache_itlb_comm_i.g_enable = 1'b1;
            tb_icache_itlb_comm_i.req.vpn = 27'h402A21;
            $display("Testing with vpn %x (vm, vs, and g enabled)", tb_icache_itlb_comm_i.req.vpn);
            tb_icache_itlb_comm_i.req.valid = 1'b1;
            tick();
            tb_icache_itlb_comm_i.req.valid = 1'b0;
            tick();
            wait(tb_itlb_icache_comm_o.tlb_ready);
            $display("Time is %0t",$time); 
            $display("result virtualized environment itlb + ptw: %x", tb_itlb_icache_comm_o.resp.ppn);
            #0;
            $display("Time is %0t",$time); 
            $display("result virtualized environment itlb + ptw: %x", tb_itlb_icache_comm_o.resp.ppn);
            tick();
        end
    endtask

//***init_sim***
//The tasks that compose my testbench are executed here, feel free to add more tasks.
    initial begin
        init_sim();
        init_dump();
        reset_dut();
        test_sim();
        $finish;
    end
endmodule

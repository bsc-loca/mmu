/*
 * Copyright 2025 BSC*
 * *Barcelona Supercomputing Center (BSC)
 * 
 * SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 * 
 * Licensed under the Solderpad Hardware License v 2.1 (the “License”); you
 * may not use this file except in compliance with the License, or, at your
 * option, the Apache License version 2.0. You may obtain a copy of the
 * License at
 * 
 * https://solderpad.org/licenses/SHL-2.1/
 * 
 * Unless required by applicable law or agreed to in writing, any work
 * distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

module mmu_top
import mmu_pkg::*;
#(
)(
    input logic clk_i,
    input logic rstn_i,

    //-------------- TLB --------------
    // iTLB request-response
    input  cache_tlb_comm_t icache_itlb_comm_i,   // Communication from translation requester to iTLB.
    output tlb_cache_comm_t itlb_icache_comm_o,   // Communication from iTLB to translation requester.

    // dTLB request-response
    input  cache_tlb_comm_t core_dtlb_comm_i,   // Communication from translation requester to dTLB.
    output tlb_cache_comm_t dtlb_core_comm_o,   // Communication from dTLB to translation requester.

    // PMU counter events
    output logic pmu_itlb_access_o,              // Accepted Translation request to iTLB. 
    output logic pmu_itlb_miss_o,                // Accepted Translation request to iTLB misses. 
    output logic pmu_dtlb_access_o,              // Accepted Translation request to dTLB. 
    output logic pmu_dtlb_miss_o,                // Accepted Translation request to dTLB misses. 

    //-------------- PTW --------------
    // dmem request-response
    input  dmem_ptw_comm_t dmem_ptw_comm_i,
    output ptw_dmem_comm_t ptw_dmem_comm_o,

    // csr interface
    input csr_ptw_comm_t csr_ptw_comm_i,

    // pmu interface
    output logic pmu_ptw_hit_o,
    output logic pmu_ptw_miss_o
);

tlb_ptw_comm_t itlb_ptw_comm, dtlb_ptw_comm;
ptw_tlb_comm_t ptw_itlb_comm, ptw_dtlb_comm;

/**************************************************/
/* --                iTLB                      -- */
/**************************************************/
tlb itlb (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .cache_tlb_comm_i(icache_itlb_comm_i),
    .tlb_cache_comm_o(itlb_icache_comm_o),
    .ptw_tlb_comm_i(ptw_itlb_comm),
    .tlb_ptw_comm_o(itlb_ptw_comm),
    .pmu_tlb_access_o(pmu_itlb_access_o),
    .pmu_tlb_miss_o(pmu_itlb_miss_o)
);

/**************************************************/
/* --                dTLB                      -- */
/**************************************************/
tlb dtlb (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .cache_tlb_comm_i(core_dtlb_comm_i),
    .tlb_cache_comm_o(dtlb_core_comm_o),
    .ptw_tlb_comm_i(ptw_dtlb_comm),
    .tlb_ptw_comm_o(dtlb_ptw_comm),
    .pmu_tlb_access_o(pmu_dtlb_access_o),
    .pmu_tlb_miss_o(pmu_dtlb_miss_o)
);

/**************************************************/
/* --                 PTW                      -- */
/**************************************************/
ptw ptw_inst (
    .clk_i(clk_i),
    .rstn_i(rstn_i),

    // iTLB request-response
    .itlb_ptw_comm_i(itlb_ptw_comm), 
    .ptw_itlb_comm_o(ptw_itlb_comm),

    // dTLB request-response
    .dtlb_ptw_comm_i(dtlb_ptw_comm),
    .ptw_dtlb_comm_o(ptw_dtlb_comm),

    // dmem request-response
    .dmem_ptw_comm_i(dmem_ptw_comm_i),
    .ptw_dmem_comm_o(ptw_dmem_comm_o),

    // csr interface
    .csr_ptw_comm_i(csr_ptw_comm_i),

    // pmu interface
    .pmu_ptw_hit_o(pmu_ptw_hit_o),
    .pmu_ptw_miss_o(pmu_ptw_miss_o)
);

endmodule

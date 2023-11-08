/*
 * Copyright 2023 BSC*
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

module tlb_wrapper 
import mmu_pkg::*;
#(
)(
    input logic clk_i,
    input logic rstn_i,
    // cache interface  
    input logic mem_treq_i_valid,
    input logic [6:0]  mem_treq_i_asid,
    input logic [27:0] mem_treq_i_vpn,
    input logic mem_treq_i_passthrough,
    input logic mem_treq_i_instruction,
    input logic mem_treq_i_store,
    output logic mem_req_ready_o,
    output logic tlb_tresp_o_miss,
    output logic [19:0] tlb_tresp_o_ppn,
    output logic tlb_tresp_o_xcpt__if,
    output logic tlb_tresp_o_xcpt_ld,
    output logic tlb_tresp_o_xcpt_st,
    output logic [7:0] tlb_tresp_o_hit_idx,
    // ptw interface
    input logic ptw_req_ready_i,                  
    input logic ptw_invalidate_i,                  
    input logic ptw_resp_i_valid,
    input logic ptw_resp_i_error,
    input logic [19:0] ptw_resp_i_pte_ppn,                  
    input logic [1:0] ptw_resp_i_pte_rfs,
    input logic ptw_resp_i_pte_d,
    input logic ptw_resp_i_pte_a,
    input logic ptw_resp_i_pte_g,
    input logic ptw_resp_i_pte_u,
    input logic ptw_resp_i_pte_x,
    input logic ptw_resp_i_pte_w,
    input logic ptw_resp_i_pte_r,
    input logic ptw_resp_i_pte_v,
    input logic [1:0] ptw_resp_i_level,
    input logic ptw_status_i_sd,
    input logic [26:0] ptw_status_i_zero5,
    input logic [1:0] ptw_status_i_sxl,
    input logic [1:0] ptw_status_i_uxl,
    input logic [8:0] ptw_status_i_zero4,
    input logic ptw_status_i_tsr,
    input logic ptw_status_i_tw,
    input logic ptw_status_i_tvm,
    input logic ptw_status_i_mxr,
    input logic ptw_status_i_sum,
    input logic ptw_status_i_mprv,
    input logic [1:0] ptw_status_i_xs,
    input logic [1:0] ptw_status_i_fs,
    input logic [1:0] ptw_status_i_mpp,
    input logic [1:0] ptw_status_i_zero3,
    input logic ptw_status_i_spp,
    input logic ptw_status_i_mpie,
    input logic ptw_status_i_zero2,
    input logic ptw_status_i_spie,
    input logic ptw_status_i_upie,
    input logic ptw_status_i_mie,
    input logic ptw_status_i_zero1,
    input logic ptw_status_i_sie,
    input logic ptw_status_i_uie,         
    output logic ptw_req_o_valid,
    output logic [26:0] ptw_req_o_addr,
    output logic [1:0] ptw_req_o_prv,
    output logic ptw_req_o_store,
    output logic ptw_req_o_fetch,
    // csr interface                                  
    input logic [1:0] csr_priv_lvl_i,                  
    input logic csr_en_translation_i,
    // pmu interface 
    output logic pmu_tlb_access_o,
    output logic pmu_tlb_miss_o
);

cache_tlb_comm_t cache_tlb_comm;
tlb_cache_comm_t tlb_cache_comm;
tlb_ptw_comm_t tlb_ptw_comm;
ptw_tlb_comm_t ptw_tlb_comm;

// INPUTS
// cache_tlb_comm assignaments
assign cache_tlb_comm.req.valid = mem_treq_i_valid;
assign cache_tlb_comm.req.asid = mem_treq_i_asid;
assign cache_tlb_comm.req.vpn = mem_treq_i_vpn;
assign cache_tlb_comm.req.passthrough = mem_treq_i_passthrough;
assign cache_tlb_comm.req.instruction = mem_treq_i_instruction;
assign cache_tlb_comm.req.store = mem_treq_i_store;
assign cache_tlb_comm.priv_lvl = csr_priv_lvl_i;
assign cache_tlb_comm.vm_enable = csr_en_translation_i;

// ptw_tlb_comm assignaments
assign ptw_tlb_comm.resp.valid = ptw_resp_i_valid;
assign ptw_tlb_comm.resp.error = ptw_resp_i_error;
assign ptw_tlb_comm.resp.pte.ppn = ptw_resp_i_pte_ppn;
assign ptw_tlb_comm.resp.pte.rfs = ptw_resp_i_pte_rfs;
assign ptw_tlb_comm.resp.pte.d = ptw_resp_i_pte_d;
assign ptw_tlb_comm.resp.pte.a = ptw_resp_i_pte_a;
assign ptw_tlb_comm.resp.pte.g = ptw_resp_i_pte_g;
assign ptw_tlb_comm.resp.pte.u = ptw_resp_i_pte_u;
assign ptw_tlb_comm.resp.pte.x = ptw_resp_i_pte_x; 
assign ptw_tlb_comm.resp.pte.w = ptw_resp_i_pte_w;
assign ptw_tlb_comm.resp.pte.r = ptw_resp_i_pte_r;
assign ptw_tlb_comm.resp.pte.v = ptw_resp_i_pte_v;
assign ptw_tlb_comm.resp.level = ptw_resp_i_level;
assign ptw_tlb_comm.ptw_ready = ptw_req_ready_i;
assign ptw_tlb_comm.ptw_status.sd = ptw_status_i_sd;
assign ptw_tlb_comm.ptw_status.zero5 = ptw_status_i_zero5;
assign ptw_tlb_comm.ptw_status.sxl = ptw_status_i_sxl;
assign ptw_tlb_comm.ptw_status.uxl = ptw_status_i_uxl;
assign ptw_tlb_comm.ptw_status.zero4 = ptw_status_i_zero4;
assign ptw_tlb_comm.ptw_status.tsr = ptw_status_i_tsr;
assign ptw_tlb_comm.ptw_status.tw = ptw_status_i_tw;
assign ptw_tlb_comm.ptw_status.tvm = ptw_status_i_tvm;
assign ptw_tlb_comm.ptw_status.mxr = ptw_status_i_mxr;
assign ptw_tlb_comm.ptw_status.sum = ptw_status_i_sum;
assign ptw_tlb_comm.ptw_status.mprv = ptw_status_i_mprv;
assign ptw_tlb_comm.ptw_status.xs = ptw_status_i_xs;
assign ptw_tlb_comm.ptw_status.fs = ptw_status_i_fs;
assign ptw_tlb_comm.ptw_status.mpp = ptw_status_i_mpp;
assign ptw_tlb_comm.ptw_status.zero3 = ptw_status_i_zero3;
assign ptw_tlb_comm.ptw_status.spp = ptw_status_i_spp;
assign ptw_tlb_comm.ptw_status.mpie = ptw_status_i_mpie;
assign ptw_tlb_comm.ptw_status.zero2 = ptw_status_i_zero2;
assign ptw_tlb_comm.ptw_status.spie = ptw_status_i_spie;
assign ptw_tlb_comm.ptw_status.upie = ptw_status_i_upie;
assign ptw_tlb_comm.ptw_status.mie = ptw_status_i_mie;
assign ptw_tlb_comm.ptw_status.zero1 = ptw_status_i_zero1;
assign ptw_tlb_comm.ptw_status.sie = ptw_status_i_sie;
assign ptw_tlb_comm.ptw_status.uie = ptw_status_i_uie;  
assign ptw_tlb_comm.invalidate_tlb = ptw_invalidate_i;

tlb tlb_inst (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .cache_tlb_comm_i(cache_tlb_comm),
    .tlb_cache_comm_o(tlb_cache_comm),
    .ptw_tlb_comm_i(ptw_tlb_comm),
    .tlb_ptw_comm_o(tlb_ptw_comm),
    .pmu_tlb_access_o(pmu_tlb_access_o),
    .pmu_tlb_miss_o(pmu_tlb_miss_o)
);

// OUTPUTS
assign mem_req_ready_o = tlb_cache_comm.tlb_ready;
assign tlb_tresp_o_miss = tlb_cache_comm.resp.miss;
assign tlb_tresp_o_ppn = tlb_cache_comm.resp.ppn;
assign tlb_tresp_o_xcpt_ld = tlb_cache_comm.resp.xcpt.load;
assign tlb_tresp_o_xcpt_st = tlb_cache_comm.resp.xcpt.store;
assign tlb_tresp_o_xcpt__if = tlb_cache_comm.resp.xcpt.fetch;
assign tlb_tresp_o_hit_idx = '0;
assign ptw_req_o_valid = tlb_ptw_comm.req.valid;
assign ptw_req_o_addr = tlb_ptw_comm.req.vpn;
assign ptw_req_o_prv = tlb_ptw_comm.req.prv;
assign ptw_req_o_store = tlb_ptw_comm.req.store;
assign ptw_req_o_fetch = tlb_ptw_comm.req.fetch;

endmodule

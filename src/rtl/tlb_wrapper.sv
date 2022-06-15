/* -----------------------------------------------
 * Project Name   : OpenPiton + Lagarto
 * File           : tlb_wrapper.sv
 * Organization   : Barcelona Supercomputing Center
 * Author(s)      : Neiel I. Leyva Santes
 *                : Xavier Carril Gil 
 *                : Javier Salamero Sanz 
 * Email(s)       : neiel.leyva@bsc.es
 *                : xavier.carril@bsc.es
 *                : javier.salamero@bsc.es
 * References     : 
 * -----------------------------------------------
 * Revision History
 *  Revision   | Author    | Commit | Description
 *  ******     | Neiel L.  |        | 
 * -----------------------------------------------
 */

import mmu_pkg::*;

module tlb_wrapper(
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

`ifndef TLB_CHISEL
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

`else
TLB_chisel tlb(.clk ( clk_i ), .reset ( ~rstn_i ), // works on a positive edge
    .io_req_ready                               ( mem_req_ready_o        ),  
    .io_req_valid                               ( mem_treq_i_valid       ),
    .io_req_bits_asid                           ( mem_treq_i_asid        ),
    .io_req_bits_vpn                            ( mem_treq_i_vpn         ),
    .io_req_bits_passthrough                    ( mem_treq_i_passthrough ),
    .io_req_bits_instruction                    ( mem_treq_i_instruction ),
    .io_req_bits_store                          ( mem_treq_i_store       ), 
    .io_resp_miss                               ( tlb_tresp_o_miss       ),
    .io_resp_ppn                                ( tlb_tresp_o_ppn        ),
    .io_resp_xcpt_ld                            ( tlb_tresp_o_xcpt_ld    ),
    .io_resp_xcpt_st                            ( tlb_tresp_o_xcpt_st    ),
    .io_resp_xcpt_if                            ( tlb_tresp_o_xcpt__if   ),
    .io_resp_hit_idx                            ( tlb_tresp_o_hit_idx    ),
    .io_ptw_req_ready                           ( ptw_req_ready_i        ),
    .io_ptw_req_valid                           ( ptw_req_o_valid        ),
    .io_ptw_req_bits_addr                       ( ptw_req_o_addr         ),
    .io_ptw_req_bits_prv                        ( ptw_req_o_prv          ),
    .io_ptw_req_bits_store                      ( ptw_req_o_store        ),
    .io_ptw_req_bits_fetch                      ( ptw_req_o_fetch        ), 
    .io_ptw_resp_valid                          ( ptw_resp_i_valid       ),
    .io_ptw_resp_bits_error                     ( ptw_resp_i_error       ),
    .io_ptw_resp_bits_pte_ppn                   ( ptw_resp_i_pte_ppn     ),
    .io_ptw_resp_bits_pte_reserved_for_software ( ptw_resp_i_pte_rfs     ),
    .io_ptw_resp_bits_pte_d                     ( ptw_resp_i_pte_d       ),
    .io_ptw_resp_bits_pte_a                     ( ptw_resp_i_pte_a       ),
    .io_ptw_resp_bits_pte_g                     ( ptw_resp_i_pte_g       ),
    .io_ptw_resp_bits_pte_u                     ( ptw_resp_i_pte_u       ),
    .io_ptw_resp_bits_pte_x                     ( ptw_resp_i_pte_x       ),
    .io_ptw_resp_bits_pte_w                     ( ptw_resp_i_pte_w       ),
    .io_ptw_resp_bits_pte_r                     ( ptw_resp_i_pte_r       ),
    .io_ptw_resp_bits_pte_v                     ( ptw_resp_i_pte_v       ),
    .io_ptw_resp_bits_level                     ( ptw_resp_i_level       ),
    .io_ptw_status_sd                           ( ptw_status_i_sd        ),
    .io_ptw_status_zero5                        ( ptw_status_i_zero5     ),
    .io_ptw_status_sxl                          ( ptw_status_i_sxl       ),
    .io_ptw_status_uxl                          ( ptw_status_i_uxl       ),
    .io_ptw_status_zero4                        ( ptw_status_i_zero4     ),
    .io_ptw_status_tsr                          ( ptw_status_i_tsr       ),
    .io_ptw_status_tw                           ( ptw_status_i_tw        ),
    .io_ptw_status_tvm                          ( ptw_status_i_tvm       ),
    .io_ptw_status_mxr                          ( ptw_status_i_mxr       ),
    .io_ptw_status_sum                          ( ptw_status_i_sum       ),
    .io_ptw_status_mprv                         ( ptw_status_i_mprv      ),
    .io_ptw_status_xs                           ( ptw_status_i_xs        ),
    .io_ptw_status_fs                           ( ptw_status_i_fs        ),
    .io_ptw_status_mpp                          ( ptw_status_i_mpp       ),
    .io_ptw_status_zero3                        ( ptw_status_i_zero3     ),
    .io_ptw_status_spp                          ( ptw_status_i_spp       ),
    .io_ptw_status_mpie                         ( ptw_status_i_mpie      ),
    .io_ptw_status_zero2                        ( ptw_status_i_zero2     ),
    .io_ptw_status_spie                         ( ptw_status_i_spie      ),
    .io_ptw_status_upie                         ( ptw_status_i_upie      ),
    .io_ptw_status_mie                          ( ptw_status_i_mie       ),
    .io_ptw_status_zero1                        ( ptw_status_i_zero1     ),
    .io_ptw_status_sie                          ( ptw_status_i_sie       ),
    .io_ptw_status_uie                          ( ptw_status_i_uie       ),
    .io_ptw_invalidate                          ( ptw_invalidate_i       ),
    .io_priv_lvl                                ( csr_priv_lvl_i         ),
    .io_en_translation                          ( csr_en_translation_i   )   
);
`endif

endmodule

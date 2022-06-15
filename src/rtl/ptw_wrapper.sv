/* -----------------------------------------------
 * Project Name   : OpenPiton + Lagarto
 * File           : ptw_wrapper.sv
 * Organization   : Barcelona Supercomputing Center
 * Author(s)      : Neiel I. Leyva Santes. 
 * Email(s)       : neiel.leyva@bsc.es
 * References     : 
 * -----------------------------------------------
 * Revision History
 *  Revision   | Author    | Commit | Description
 *  ******     | Neiel L.  |        | 
 * -----------------------------------------------
 */

import lagarto_tile_pkg::*;
import mmu_pkg::*;

module ptw_wrapper(
    input  logic         clk_i             ,
    input  logic         rstn_i            ,
    // dtlb interface                             
    input  tlb_req_t     dtlb_req_i        , 
    output ptw_resp_t    dtlb_resp_o       ,
    output mstatus_t     dtlb_status_o     ,
    output logic         dtlb_invalidate_o ,
    output logic         dtlb_req_ready_o  ,
    // itlb interface                         
    input  tlb_req_t     itlb_req_i        , 
    output ptw_resp_t    itlb_resp_o       ,
    output mstatus_t     itlb_status_o     ,
    output logic         itlb_invalidate_o ,
    output logic         itlb_req_ready_o  ,
    // dcache interface                           
    input  logic         dmem_req_ready_i  ,
    input  dmem_resp_t   dmem_resp_i       , 
    output dmem_req_t    dmem_req_o        ,
    // CSR interface                           
    input  b32_t         csr_satp_i        ,
    input  logic         csr_flush_i       ,
    input  mstatus_t     csr_status_i      ,
    // PMU interface
    output logic         pmu_ptw_hit_o     ,
    output logic         pmu_ptw_miss_o
);

`ifndef PTW_CHISEL 

// Struct instantations
tlb_ptw_comm_t itlb_ptw_comm;
ptw_tlb_comm_t ptw_itlb_comm;
tlb_ptw_comm_t dtlb_ptw_comm;
ptw_tlb_comm_t ptw_dtlb_comm;
dmem_ptw_comm_t dmem_ptw_comm;
ptw_dmem_comm_t ptw_dmem_comm;
csr_ptw_comm_t csr_ptw_comm;

/** Package assignations **/

//iTLB
assign itlb_ptw_comm.req.valid  = itlb_req_i.valid;
assign itlb_ptw_comm.req.vpn    = itlb_req_i.addr;
assign itlb_ptw_comm.req.prv    = itlb_req_i.prv;
assign itlb_ptw_comm.req.store  = itlb_req_i.store;
assign itlb_ptw_comm.req.fetch  = itlb_req_i.fetch;
assign itlb_resp_o.valid        = ptw_itlb_comm.resp.valid;
assign itlb_resp_o.error        = ptw_itlb_comm.resp.error;
assign itlb_resp_o.pte_ppn      = ptw_itlb_comm.resp.pte.ppn[19:0];
assign itlb_resp_o.pte_rfs      = ptw_itlb_comm.resp.pte.rfs;
assign itlb_resp_o.pte_d        = ptw_itlb_comm.resp.pte.d;
assign itlb_resp_o.pte_a        = ptw_itlb_comm.resp.pte.a;
assign itlb_resp_o.pte_g        = ptw_itlb_comm.resp.pte.g;
assign itlb_resp_o.pte_u        = ptw_itlb_comm.resp.pte.u;
assign itlb_resp_o.pte_x        = ptw_itlb_comm.resp.pte.x;
assign itlb_resp_o.pte_w        = ptw_itlb_comm.resp.pte.w;
assign itlb_resp_o.pte_r        = ptw_itlb_comm.resp.pte.r;
assign itlb_resp_o.pte_v        = ptw_itlb_comm.resp.pte.v;
assign itlb_resp_o.level        = ptw_itlb_comm.resp.level;
assign itlb_status_o            = ptw_itlb_comm.ptw_status;
assign itlb_invalidate_o        = ptw_itlb_comm.invalidate_tlb;
assign itlb_req_ready_o         = ptw_itlb_comm.ptw_ready;

//dTLB
assign dtlb_ptw_comm.req.valid  = dtlb_req_i.valid;
assign dtlb_ptw_comm.req.vpn    = dtlb_req_i.addr;
assign dtlb_ptw_comm.req.prv    = dtlb_req_i.prv;
assign dtlb_ptw_comm.req.store  = dtlb_req_i.store;
assign dtlb_ptw_comm.req.fetch  = dtlb_req_i.fetch;
assign dtlb_resp_o.valid        = ptw_dtlb_comm.resp.valid;
assign dtlb_resp_o.error        = ptw_dtlb_comm.resp.error;
assign dtlb_resp_o.pte_ppn      = ptw_dtlb_comm.resp.pte.ppn[19:0];
assign dtlb_resp_o.pte_rfs      = ptw_dtlb_comm.resp.pte.rfs;
assign dtlb_resp_o.pte_d        = ptw_dtlb_comm.resp.pte.d;
assign dtlb_resp_o.pte_a        = ptw_dtlb_comm.resp.pte.a;
assign dtlb_resp_o.pte_g        = ptw_dtlb_comm.resp.pte.g;
assign dtlb_resp_o.pte_u        = ptw_dtlb_comm.resp.pte.u;
assign dtlb_resp_o.pte_x        = ptw_dtlb_comm.resp.pte.x;
assign dtlb_resp_o.pte_w        = ptw_dtlb_comm.resp.pte.w;
assign dtlb_resp_o.pte_r        = ptw_dtlb_comm.resp.pte.r;
assign dtlb_resp_o.pte_v        = ptw_dtlb_comm.resp.pte.v;
assign dtlb_resp_o.level        = ptw_dtlb_comm.resp.level;
assign dtlb_status_o            = ptw_dtlb_comm.ptw_status;
assign dtlb_invalidate_o        = ptw_dtlb_comm.invalidate_tlb;
assign dtlb_req_ready_o         = ptw_dtlb_comm.ptw_ready;

//dMem
assign dmem_ptw_comm.dmem_ready      = dmem_req_ready_i;
assign dmem_ptw_comm.resp.valid      = dmem_resp_i.valid;
assign dmem_ptw_comm.resp.addr       = dmem_resp_i.addr;
assign dmem_ptw_comm.resp.tag_addr   = dmem_resp_i.tag_addr;
assign dmem_ptw_comm.resp.cmd        = dmem_resp_i.cmd;
assign dmem_ptw_comm.resp.typ        = dmem_resp_i.typ;
assign dmem_ptw_comm.resp.data       = dmem_resp_i.data;
assign dmem_ptw_comm.resp.nack       = dmem_resp_i.nack;
assign dmem_ptw_comm.resp.replay     = dmem_resp_i.replay;
assign dmem_ptw_comm.resp.has_data   = dmem_resp_i.has_data;
assign dmem_ptw_comm.resp.data_subw  = dmem_resp_i.data_subw;
assign dmem_ptw_comm.resp.store_data = dmem_resp_i.store_data;
assign dmem_ptw_comm.resp.rnvalid    = dmem_resp_i.rnvalid;
assign dmem_ptw_comm.resp.rnext      = dmem_resp_i.rnext;
assign dmem_ptw_comm.resp.xcpt_ma_ld = dmem_resp_i.xcpt_ma_ld;
assign dmem_ptw_comm.resp.xcpt_ma_st = dmem_resp_i.xcpt_ma_st;
assign dmem_ptw_comm.resp.xcpt_pf_ld = dmem_resp_i.xcpt_pf_ld;
assign dmem_ptw_comm.resp.xcpt_pf_st = dmem_resp_i.xcpt_pf_st;
assign dmem_ptw_comm.resp.ordered    = dmem_resp_i.ordered;

assign dmem_req_o.valid = ptw_dmem_comm.req.valid;
assign dmem_req_o.addr  = ptw_dmem_comm.req.addr;
assign dmem_req_o.cmd   = ptw_dmem_comm.req.cmd;
assign dmem_req_o.typ   = ptw_dmem_comm.req.typ;
assign dmem_req_o.kill  = ptw_dmem_comm.req.kill;
assign dmem_req_o.phys  = ptw_dmem_comm.req.phys;
assign dmem_req_o.data  = ptw_dmem_comm.req.data;

//CSR
assign csr_ptw_comm.satp = {32'b0, csr_satp_i}; //The PTW obtains ALWAYS a satp of 64 bits
assign csr_ptw_comm.flush = csr_flush_i;
assign csr_ptw_comm.mstatus = csr_status_i;

ptw ptw_inst(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .itlb_ptw_comm_i(itlb_ptw_comm),
    .ptw_itlb_comm_o(ptw_itlb_comm),
    .dtlb_ptw_comm_i(dtlb_ptw_comm),
    .ptw_dtlb_comm_o(ptw_dtlb_comm),
    .dmem_ptw_comm_i(dmem_ptw_comm),
    .ptw_dmem_comm_o(ptw_dmem_comm),
    .csr_ptw_comm_i(csr_ptw_comm),
    .pmu_ptw_hit_o(pmu_ptw_hit_o),
    .pmu_ptw_miss_o(pmu_ptw_miss_o)
);

`else

// PTW generated from Chisel
PTW_chisel ptw_top(.clk ( clk_i ), .reset ( ~rstn_i ), // works on a positive edge
    .io_requestor_1_req_valid                           ( dtlb_req_i.valid       ),
    .io_requestor_1_req_bits_addr                       ( dtlb_req_i.addr        ),
    .io_requestor_1_req_bits_prv                        ( dtlb_req_i.prv         ),
    .io_requestor_1_req_bits_store                      ( dtlb_req_i.store       ),
    .io_requestor_1_req_bits_fetch                      ( dtlb_req_i.fetch       ), 
    .io_requestor_1_req_ready                           ( dtlb_req_ready_o       ), 
    .io_requestor_1_resp_valid                          ( dtlb_resp_o.valid      ),
    .io_requestor_1_resp_bits_error                     ( dtlb_resp_o.error      ),
    .io_requestor_1_resp_bits_pte_ppn                   ( dtlb_resp_o.pte_ppn    ),
    .io_requestor_1_resp_bits_pte_reserved_for_software ( dtlb_resp_o.pte_rfs    ),
    .io_requestor_1_resp_bits_pte_d                     ( dtlb_resp_o.pte_d      ),
    .io_requestor_1_resp_bits_pte_a                     ( dtlb_resp_o.pte_a      ),
    .io_requestor_1_resp_bits_pte_g                     ( dtlb_resp_o.pte_g      ),
    .io_requestor_1_resp_bits_pte_u                     ( dtlb_resp_o.pte_u      ),
    .io_requestor_1_resp_bits_pte_x                     ( dtlb_resp_o.pte_x      ),
    .io_requestor_1_resp_bits_pte_w                     ( dtlb_resp_o.pte_w      ),
    .io_requestor_1_resp_bits_pte_r                     ( dtlb_resp_o.pte_r      ),
    .io_requestor_1_resp_bits_pte_v                     ( dtlb_resp_o.pte_v      ),
    .io_requestor_1_resp_bits_level                     ( dtlb_resp_o.level      ),  
    .io_requestor_1_status_sd                           ( dtlb_status_o.sd       ),
    .io_requestor_1_status_zero5                        ( dtlb_status_o.zero5    ),
    .io_requestor_1_status_sxl                          ( dtlb_status_o.sxl      ),
    .io_requestor_1_status_uxl                          ( dtlb_status_o.uxl      ),
    .io_requestor_1_status_zero4                        ( dtlb_status_o.zero4    ),
    .io_requestor_1_status_tsr                          ( dtlb_status_o.tsr      ),
    .io_requestor_1_status_tw                           ( dtlb_status_o.tw       ),
    .io_requestor_1_status_tvm                          ( dtlb_status_o.tvm      ),
    .io_requestor_1_status_mxr                          ( dtlb_status_o.mxr      ),
    .io_requestor_1_status_sum                          ( dtlb_status_o.sum      ),
    .io_requestor_1_status_mprv                         ( dtlb_status_o.mprv     ),
    .io_requestor_1_status_xs                           ( dtlb_status_o.xs       ),
    .io_requestor_1_status_fs                           ( dtlb_status_o.fs       ),
    .io_requestor_1_status_mpp                          ( dtlb_status_o.mpp      ),
    .io_requestor_1_status_zero3                        ( dtlb_status_o.zero3    ),
    .io_requestor_1_status_spp                          ( dtlb_status_o.spp      ),
    .io_requestor_1_status_mpie                         ( dtlb_status_o.mpie     ),
    .io_requestor_1_status_zero2                        ( dtlb_status_o.zero2    ),
    .io_requestor_1_status_spie                         ( dtlb_status_o.spie     ),
    .io_requestor_1_status_upie                         ( dtlb_status_o.upie     ),
    .io_requestor_1_status_mie                          ( dtlb_status_o.mie      ),
    .io_requestor_1_status_zero1                        ( dtlb_status_o.zero1    ),
    .io_requestor_1_status_sie                          ( dtlb_status_o.sie      ),
    .io_requestor_1_status_uie                          ( dtlb_status_o.uie      ), 
    .io_requestor_1_invalidate                          ( dtlb_invalidate_o      ), 
    .io_requestor_0_req_valid                           ( itlb_req_i.valid       ),
    .io_requestor_0_req_bits_addr                       ( itlb_req_i.addr        ),
    .io_requestor_0_req_bits_prv                        ( itlb_req_i.prv         ),
    .io_requestor_0_req_bits_store                      ( itlb_req_i.store       ),
    .io_requestor_0_req_bits_fetch                      ( itlb_req_i.fetch       ), 
    .io_requestor_0_req_ready                           ( itlb_req_ready_o       ),
    .io_requestor_0_resp_valid                          ( itlb_resp_o.valid      ),
    .io_requestor_0_resp_bits_error                     ( itlb_resp_o.error      ),
    .io_requestor_0_resp_bits_pte_ppn                   ( itlb_resp_o.pte_ppn    ),
    .io_requestor_0_resp_bits_pte_reserved_for_software ( itlb_resp_o.pte_rfs    ),
    .io_requestor_0_resp_bits_pte_d                     ( itlb_resp_o.pte_d      ),
    .io_requestor_0_resp_bits_pte_a                     ( itlb_resp_o.pte_a      ),
    .io_requestor_0_resp_bits_pte_g                     ( itlb_resp_o.pte_g      ),
    .io_requestor_0_resp_bits_pte_u                     ( itlb_resp_o.pte_u      ),
    .io_requestor_0_resp_bits_pte_x                     ( itlb_resp_o.pte_x      ),
    .io_requestor_0_resp_bits_pte_w                     ( itlb_resp_o.pte_w      ),
    .io_requestor_0_resp_bits_pte_r                     ( itlb_resp_o.pte_r      ),
    .io_requestor_0_resp_bits_pte_v                     ( itlb_resp_o.pte_v      ),
    .io_requestor_0_resp_bits_level                     ( itlb_resp_o.level      ),
    .io_requestor_0_status_sd                           ( itlb_status_o.sd       ),
    .io_requestor_0_status_zero5                        ( itlb_status_o.zero5    ),
    .io_requestor_0_status_sxl                          ( itlb_status_o.sxl      ),
    .io_requestor_0_status_uxl                          ( itlb_status_o.uxl      ),
    .io_requestor_0_status_zero4                        ( itlb_status_o.zero4    ),
    .io_requestor_0_status_tsr                          ( itlb_status_o.tsr      ),
    .io_requestor_0_status_tw                           ( itlb_status_o.tw       ),
    .io_requestor_0_status_tvm                          ( itlb_status_o.tvm      ),
    .io_requestor_0_status_mxr                          ( itlb_status_o.mxr      ),
    .io_requestor_0_status_sum                          ( itlb_status_o.sum      ),
    .io_requestor_0_status_mprv                         ( itlb_status_o.mprv     ),
    .io_requestor_0_status_xs                           ( itlb_status_o.xs       ),
    .io_requestor_0_status_fs                           ( itlb_status_o.fs       ),
    .io_requestor_0_status_mpp                          ( itlb_status_o.mpp      ),
    .io_requestor_0_status_zero3                        ( itlb_status_o.zero3    ),
    .io_requestor_0_status_spp                          ( itlb_status_o.spp      ),
    .io_requestor_0_status_mpie                         ( itlb_status_o.mpie     ),
    .io_requestor_0_status_zero2                        ( itlb_status_o.zero2    ),
    .io_requestor_0_status_spie                         ( itlb_status_o.spie     ),
    .io_requestor_0_status_upie                         ( itlb_status_o.upie     ),
    .io_requestor_0_status_mie                          ( itlb_status_o.mie      ),
    .io_requestor_0_status_zero1                        ( itlb_status_o.zero1    ),
    .io_requestor_0_status_sie                          ( itlb_status_o.sie      ),
    .io_requestor_0_status_uie                          ( itlb_status_o.uie      ),
    .io_requestor_0_invalidate                          ( itlb_invalidate_o      ),
    .io_mem_req_ready                                   ( dmem_req_ready_i       ),
    .io_mem_req_valid                                   ( dmem_req_o.valid       ),
    .io_mem_req_bits_addr                               ( dmem_req_o.addr        ),
    .io_mem_req_bits_cmd                                ( dmem_req_o.cmd         ),
    .io_mem_req_bits_typ                                ( dmem_req_o.typ         ),
    .io_mem_req_bits_kill                               ( dmem_req_o.kill        ),
    .io_mem_req_bits_phys                               ( dmem_req_o.phys        ),
    .io_mem_req_bits_data                               ( dmem_req_o.data        ),
    .io_mem_resp_valid                                  ( dmem_resp_i.valid      ),
    .io_mem_resp_bits_addr                              ( dmem_resp_i.addr       ),
    .io_mem_resp_bits_tag                               ( dmem_resp_i.tag_addr   ),
    .io_mem_resp_bits_cmd                               ( dmem_resp_i.cmd        ),
    .io_mem_resp_bits_typ                               ( dmem_resp_i.typ        ),
    .io_mem_resp_bits_data                              ( dmem_resp_i.data       ),
    .io_mem_resp_bits_nack                              ( dmem_resp_i.nack       ),
    .io_mem_resp_bits_replay                            ( dmem_resp_i.replay     ),
    .io_mem_resp_bits_has_data                          ( dmem_resp_i.has_data   ),
    .io_mem_resp_bits_data_subword                      ( dmem_resp_i.data_subw  ),
    .io_mem_resp_bits_store_data                        ( dmem_resp_i.store_data ),
    .io_mem_replay_next_valid                           ( dmem_resp_i.rnvalid    ),
    .io_mem_replay_next_bits                            ( dmem_resp_i.rnext      ), 
    .io_mem_xcpt_ma_ld                                  ( dmem_resp_i.xcpt_ma_ld ),
    .io_mem_xcpt_ma_st                                  ( dmem_resp_i.xcpt_ma_st ),
    .io_mem_xcpt_pf_ld                                  ( dmem_resp_i.xcpt_pf_ld ),
    .io_mem_xcpt_pf_st                                  ( dmem_resp_i.xcpt_pf_st ),
    .io_mem_ordered                                     ( dmem_resp_i.ordered    ), 
    .io_dpath_ptbr                                      ( csr_satp_i             ),
    .io_dpath_invalidate                                ( csr_flush_i            ),
    .io_dpath_status_sd                                 ( csr_status_i.sd        ),
    .io_dpath_status_zero5                              ( csr_status_i.zero5     ),
    .io_dpath_status_sxl                                ( csr_status_i.sxl       ),
    .io_dpath_status_uxl                                ( csr_status_i.uxl       ),
    .io_dpath_status_zero4                              ( csr_status_i.zero4     ),
    .io_dpath_status_tsr                                ( csr_status_i.tsr       ),
    .io_dpath_status_tw                                 ( csr_status_i.tw        ),
    .io_dpath_status_tvm                                ( csr_status_i.tvm       ),
    .io_dpath_status_mxr                                ( csr_status_i.mxr       ),
    .io_dpath_status_sum                                ( csr_status_i.sum       ),
    .io_dpath_status_mprv                               ( csr_status_i.mprv      ),
    .io_dpath_status_xs                                 ( csr_status_i.xs        ),
    .io_dpath_status_fs                                 ( csr_status_i.fs        ),
    .io_dpath_status_mpp                                ( csr_status_i.mpp       ),
    .io_dpath_status_zero3                              ( csr_status_i.zero3     ),
    .io_dpath_status_spp                                ( csr_status_i.spp       ),
    .io_dpath_status_mpie                               ( csr_status_i.mpie      ),
    .io_dpath_status_zero2                              ( csr_status_i.zero2     ),
    .io_dpath_status_spie                               ( csr_status_i.spie      ),
    .io_dpath_status_upie                               ( csr_status_i.upie      ),
    .io_dpath_status_mie                                ( csr_status_i.mie       ),
    .io_dpath_status_zero1                              ( csr_status_i.zero1     ),
    .io_dpath_status_sie                                ( csr_status_i.sie       ),
    .io_dpath_status_uie                                ( csr_status_i.uie       )
 );
`endif
endmodule

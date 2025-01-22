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

module bsc_mmu_hpdc_adapter
import mmu_pkg::*;
#(
    parameter int unsigned SID,

    parameter type hpdcache_req_t = logic,
    parameter type hpdcache_tag_t = logic,
    parameter type hpdcache_rsp_t = logic
)(
    // PTW interface
    output dmem_ptw_comm_t              dmem_ptw_comm_o,
    input  ptw_dmem_comm_t              ptw_dmem_comm_i,

    // dCache Interface
    input  logic                        req_dcache_ready_i,
    output logic                        req_dcache_valid_o,
    output hpdcache_req_t               req_dcache_o,
    output logic                        req_dcache_abort_o,
    output hpdcache_tag_t               req_dcache_tag_o,
    output hpdcache_pkg::hpdcache_pma_t req_dcache_pma_o,
    input  logic                        rsp_dcache_valid_i,
    input  hpdcache_rsp_t               rsp_dcache_i
);

    // Number of bits used in the request's offset address
    localparam int unsigned ADDR_OFFSET_BITS = $bits(req_dcache_o.addr_offset);

    // Number of words in the request
    localparam int unsigned REQ_WORDS = $size(req_dcache_o.wdata);

    // Word size
    localparam int unsigned WORD_SIZE = $bits(req_dcache_o.wdata[0]);

    // Number of bits used to index the bytes in a word
    localparam int unsigned WORD_BYTE_IDX_SIZE = $clog2(WORD_SIZE/8);

    // Number of bits needed to index a byte within the request
    localparam int unsigned REQ_INDEX_BITS = $clog2(REQ_WORDS)+WORD_BYTE_IDX_SIZE;

    // MMU CMD that identifies an atomic OR
    localparam logic[4:0] MMU_AMO_OR = 5'b01010;

    // PTW to HPDC
    always_comb begin
        req_dcache_valid_o = ptw_dmem_comm_i.req.valid;

        req_dcache_o.addr_tag = ptw_dmem_comm_i.req.addr[SIZE_VADDR:ADDR_OFFSET_BITS];
        req_dcache_o.addr_offset = ptw_dmem_comm_i.req.addr[ADDR_OFFSET_BITS-1:0];
        req_dcache_o.op = ((ptw_dmem_comm_i.req.cmd == MMU_AMO_OR) ? hpdcache_pkg::HPDCACHE_REQ_AMO_OR : hpdcache_pkg::HPDCACHE_REQ_LOAD);
        req_dcache_o.size = ptw_dmem_comm_i.req.typ[2:0];

        // Put the data in the corresponding word within the request
        for (int unsigned i = 0; i < REQ_WORDS; ++i) begin
            if (i == ptw_dmem_comm_i.req.addr[REQ_INDEX_BITS-1:WORD_BYTE_IDX_SIZE]) begin
                req_dcache_o.wdata[i] = ptw_dmem_comm_i.req.data;
                req_dcache_o.be[i] = (ptw_dmem_comm_i.req.cmd == MMU_AMO_OR) ? 8'hff : 8'h00;
            end else begin
                req_dcache_o.wdata[i] = '0;
                req_dcache_o.be[i] = 8'h00;
            end
        end

        req_dcache_o.sid = SID;
        req_dcache_o.tid = '0;
        req_dcache_o.need_rsp = 1'b1;
        req_dcache_o.phys_indexed = 1'b1;
        req_dcache_o.pma.io = 1'b0;
        req_dcache_o.pma.uncacheable = 1'b0;
        req_dcache_o.pma.wr_policy_hint = hpdcache_pkg::HPDCACHE_WR_POLICY_AUTO;

        req_dcache_abort_o = 1'b0;
        req_dcache_tag_o = '0;
        req_dcache_pma_o = '0;
    end

    // HPDC to PTW
    always_comb begin
        dmem_ptw_comm_o.dmem_ready         = req_dcache_ready_i;
        dmem_ptw_comm_o.resp.valid         = rsp_dcache_valid_i;
        dmem_ptw_comm_o.resp.nack          = '0;
        dmem_ptw_comm_o.resp.addr          = '0;
        dmem_ptw_comm_o.resp.tag_addr      = '0;
        dmem_ptw_comm_o.resp.cmd           = '0;
        dmem_ptw_comm_o.resp.typ           = '0;
        dmem_ptw_comm_o.resp.replay        = '0;
        dmem_ptw_comm_o.resp.has_data      = '0;
        dmem_ptw_comm_o.resp.data_subw     = '0;
        dmem_ptw_comm_o.resp.store_data    = '0;
        dmem_ptw_comm_o.resp.rnvalid       = '0;
        dmem_ptw_comm_o.resp.rnext         = '0;
        dmem_ptw_comm_o.resp.xcpt_ma_ld    = '0;
        dmem_ptw_comm_o.resp.xcpt_ma_st    = '0;
        dmem_ptw_comm_o.resp.xcpt_pf_ld    = '0;
        dmem_ptw_comm_o.resp.xcpt_pf_st    = '0;
        dmem_ptw_comm_o.resp.ordered       = '0;
        dmem_ptw_comm_o.resp.data =
            rsp_dcache_i.rdata[ptw_dmem_comm_i.req.addr[REQ_INDEX_BITS-1:WORD_BYTE_IDX_SIZE]];
    end

endmodule

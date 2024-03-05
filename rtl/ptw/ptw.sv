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

module ptw 
import mmu_pkg::*;
#(
)(
    input logic clk_i,
    input logic rstn_i,

    // iTLB request-response
    input tlb_ptw_comm_t itlb_ptw_comm_i, 
    output ptw_tlb_comm_t ptw_itlb_comm_o,

    // dTLB request-response
    input tlb_ptw_comm_t dtlb_ptw_comm_i,
    output ptw_tlb_comm_t ptw_dtlb_comm_o,

    // dmem request-response
    input dmem_ptw_comm_t dmem_ptw_comm_i,
    output ptw_dmem_comm_t ptw_dmem_comm_o,

    // csr interface
    input csr_ptw_comm_t csr_ptw_comm_i,

    // pmu interface
    output logic pmu_ptw_hit_o,
    output logic pmu_ptw_miss_o
);
//Mem commands
//localparam [4:0] M_XA_OR = 5'b01010;
localparam [4:0] M_XRD = 5'b00000;
localparam [3:0] MT_D = 4'b0011;

// Page-Table Walker FSM States
typedef enum logic [2:0] {
    S_READY,
    S_REQ,
    S_WAIT,
    S_DONE,
    S_ERROR
} ptw_state;

// Signal declaration
logic [$clog2(LEVELS)-1:0] count_d, count_q;
logic [$clog2(LEVELS):0] count;

ptw_tlb_comm_t ptw_tlb_comm; 
tlb_ptw_comm_t tlb_ptw_comm; 

ptw_state current_state, next_state;

logic ptw_ready;
tlb_ptw_req_t r_req;
pte_t r_pte;
pte_t pte;
pte_t pte_wdata;

logic [PAGE_LVL_BITS-1:0] vpn_req [LEVELS-1:0];
logic [PAGE_LVL_BITS-1:0] vpn_idx;
logic [SIZE_VADDR:0] pte_addr;
logic invalid_pte;
logic valid_pte_lvl [LEVELS-1:0];
logic is_pte_leaf, is_pte_table;
logic is_pte_ur, is_pte_uw, is_pte_ux;
logic is_pte_sr, is_pte_sw, is_pte_sx;

logic [1:0] prv_req;
logic perm_ok;

logic resp_err, resp_val;
logic [63:0] r_resp_ppn;
logic [PPN_SIZE-1:0] resp_ppn_lvl [LEVELS-1:0];
logic [PPN_SIZE-1:0] resp_ppn;

logic pte_cache_hit;
logic [PPN_SIZE-1:0] pte_cache_data;

// Truncate function
function [$clog2(PTW_CACHE_SIZE)-1:0] trunc_ptw_cache_size(input [31:0] val_in);
    trunc_ptw_cache_size = val_in[$clog2(PTW_CACHE_SIZE)-1:0];
endfunction

// PTW Arbiter
ptw_arb ptw_arb_inst(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .itlb_ptw_comm_i(itlb_ptw_comm_i),
    .dtlb_ptw_comm_i(dtlb_ptw_comm_i),
    .ptw_itlb_comm_o(ptw_itlb_comm_o),
    .ptw_dtlb_comm_o(ptw_dtlb_comm_o),
    .ptw_tlb_comm_i(ptw_tlb_comm),
    .tlb_ptw_comm_o(tlb_ptw_comm)
);

// VPN indexation depending on the page level
genvar lvl;
generate
    for (lvl = 0; lvl < LEVELS; lvl++) begin
        logic [VPN_SIZE-1:0] aux_vpn_req;
        assign aux_vpn_req = (r_req.vpn >> ((LEVELS-lvl-1)*PAGE_LVL_BITS));
        assign vpn_req[lvl] = aux_vpn_req[PAGE_LVL_BITS-1:0];
    end
endgenerate
assign vpn_idx = vpn_req[count_q];

// Formatting pte data from dmem
assign pte.ppn = dmem_ptw_comm_i.resp.data[10+:(PPN_SIZE)];
assign pte.rfs = dmem_ptw_comm_i.resp.data[9:8];
assign pte.d = dmem_ptw_comm_i.resp.data[7];
assign pte.a = dmem_ptw_comm_i.resp.data[6];
assign pte.g = dmem_ptw_comm_i.resp.data[5];
assign pte.u = dmem_ptw_comm_i.resp.data[4];
assign pte.x = dmem_ptw_comm_i.resp.data[3];
assign pte.w = dmem_ptw_comm_i.resp.data[2];
assign pte.r = dmem_ptw_comm_i.resp.data[1];

genvar c;
generate
    for (c = 0; c < (LEVELS-1); c++) begin
        always_comb begin
            if (pte.r || pte.w || pte.x) begin
                valid_pte_lvl[c] = (pte.ppn[((LEVELS-c-1)*PAGE_LVL_BITS)-1:0] == '0) ? dmem_ptw_comm_i.resp.data[0] : 1'b0; //Make sure PPN LSB are 0
            end else begin
                valid_pte_lvl[c] = dmem_ptw_comm_i.resp.data[0];
            end
        end
    end
endgenerate
assign valid_pte_lvl[LEVELS-1] = dmem_ptw_comm_i.resp.data[0];
assign pte.v = valid_pte_lvl[count_q];

assign invalid_pte = ((dmem_ptw_comm_i.resp.data >> (PPN_SIZE+10)) != '0) ? 1'b1 : 1'b0; //Make sure that N, PBMT and Reserved are 0

assign is_pte_table = pte.v && !pte.x && !pte.w && !pte.r;
assign is_pte_leaf = pte.v && (pte.x || pte.w || pte.r);

assign is_pte_ur = is_pte_leaf && pte.u && pte.r;
assign is_pte_uw = is_pte_ur && pte.w;
assign is_pte_ux = pte.v && pte.x && pte.u;
assign is_pte_sr = is_pte_leaf && pte.r && !pte.u;
assign is_pte_sw = is_pte_sr && pte.w;
assign is_pte_sx = pte.v && pte.x && !pte.u;

// Page Table Entry pointer
logic [63:0] aux_pte_addr;
assign aux_pte_addr = {{(64-(PPN_SIZE+PAGE_LVL_BITS+$clog2(riscv_pkg::XLEN/8))){1'b0}}, {r_pte.ppn, vpn_idx, {{($clog2(riscv_pkg::XLEN/8))}{1'b0}}}};
assign pte_addr = aux_pte_addr[SIZE_VADDR:0] ; // For Sv39: (r_pte.ppn << 12) + (vpn_idx << 3)

// PTW Ready
assign ptw_ready = (current_state == S_READY);

// Catch Request from TLB(Arb) & PTE response from dmem
always_ff @(posedge clk_i, negedge rstn_i) begin
    if (!rstn_i) begin
        r_req <= '0;
        r_pte <= '0;
    end else begin
        if ((current_state == S_WAIT) && dmem_ptw_comm_i.resp.valid) begin
            r_pte <= pte;
        end else if ((current_state == S_REQ) && pte_cache_hit && (count_q < (LEVELS-1))) begin
            r_pte.ppn <= pte_cache_data; 
        end else if (ptw_ready & tlb_ptw_comm.req.valid) begin
            r_req <= tlb_ptw_comm.req;
            r_pte.ppn <= csr_ptw_comm_i.satp[PPN_SIZE-1:0];
        end
    end
end
`ifndef NO_PTW_CACHE
///////////////////////
// PTE cache
///////////////////////
ptw_ptecache_entry_t [PTW_CACHE_SIZE-1:0] ptecache_entry;
logic access_hit;
logic full_cache;
logic [$clog2(PTW_CACHE_SIZE)-1:0] hit_idx;
logic [$clog2(PTW_CACHE_SIZE)-1:0] plru_eviction_idx;
logic [$clog2(PTW_CACHE_SIZE)-1:0] priorityEncoder_idx;
logic [PTW_CACHE_SIZE-1:0] valid_vector;
logic [PTW_CACHE_SIZE-1:0] hit_vector;

pseudoLRU #(
    .ENTRIES(PTW_CACHE_SIZE)
) ptw_PLRU (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .access_hit_i(access_hit),
    .access_idx_i(hit_idx),
    .replacement_idx_o(plru_eviction_idx)
);

always_ff @(posedge clk_i, negedge rstn_i) begin
    if (!rstn_i) begin
        for (int i = 0; i < PTW_CACHE_SIZE; i++) begin
            ptecache_entry[i] <= '0;
            access_hit <= 1'b0;
        end
    end else begin
        access_hit <= 1'b0;
        if (dmem_ptw_comm_i.resp.valid && is_pte_table && !pte_cache_hit) begin
            if (full_cache) begin
                ptecache_entry[plru_eviction_idx].valid <= 1'b1;
                ptecache_entry[plru_eviction_idx].tags <= pte_addr;
                ptecache_entry[plru_eviction_idx].data <= pte.ppn;
            end else begin
                ptecache_entry[priorityEncoder_idx].valid <= 1'b1;
                ptecache_entry[priorityEncoder_idx].tags <= pte_addr;
                ptecache_entry[priorityEncoder_idx].data <= pte.ppn;
            end
        end
        else if (pte_cache_hit && (current_state == S_REQ)) begin
            access_hit <= 1'b1;
        end
        else if (csr_ptw_comm_i.flush) begin
            for (int i = 0; i < PTW_CACHE_SIZE; i++) begin
                ptecache_entry[i].valid <= 1'b0;
            end
        end
    end
end

always_comb begin
    for (int i = 0; i < PTW_CACHE_SIZE; i++) begin
        hit_vector[i] = ((ptecache_entry[i].tags == pte_addr) && ptecache_entry[i].valid) ? 1'b1 : 1'b0;
        valid_vector[i] = ptecache_entry[i].valid;
    end
end
assign full_cache =& valid_vector; //And Reduction
assign pte_cache_hit =| hit_vector; //Or Reduction

//Find hit index and data of the data[hit_idx]
logic found;
always_comb begin
    hit_idx = '0;
    pte_cache_data = '0;
    found = 1'b0; // Control variable
    for (int i = 0; (i < PTW_CACHE_SIZE) && (!found); i++) begin
        if (hit_vector[i]) begin
            hit_idx = trunc_ptw_cache_size(i);
            pte_cache_data = ptecache_entry[i].data;
            found = 1'b1;
        end
    end
end

//Priority Encoder
logic found2;
always_comb begin
    priorityEncoder_idx = '0;
    found2 = 1'b0;
    for (int i = 0; (i < PTW_CACHE_SIZE) && (!found2); i++) begin
        if (!valid_vector[i]) begin
            priorityEncoder_idx = trunc_ptw_cache_size(i);
            found2 = 1'b1;
        end
    end
end
/////////////////////////////////
`else
assign pte_cache_hit = 1'b0; //Temporal
assign pte_cache_data = '0;  //Temporal
`endif

// Check permissons for set_dirty
assign prv_req = r_req.prv; 

always_comb begin
    if (prv_req[0]) begin //Supervisor
        if (csr_ptw_comm_i.mstatus.sum) begin
            if (r_req.fetch) perm_ok = is_pte_sx || is_pte_ux;
            else begin
                if (r_req.store) perm_ok = is_pte_sw || is_pte_uw;
                else if (csr_ptw_comm_i.mstatus.mxr) perm_ok = is_pte_sr || is_pte_ur || is_pte_ux || is_pte_sx;
                else perm_ok = is_pte_sr || is_pte_ur;
            end
        end else begin
            if (r_req.fetch) perm_ok = is_pte_sx;
            else begin
                if (r_req.store) perm_ok = is_pte_sw;
                else if (csr_ptw_comm_i.mstatus.mxr) perm_ok = is_pte_sr || is_pte_sx;
                else perm_ok = is_pte_sr;
            end
        end
    end else begin //User
        if (r_req.fetch) perm_ok = is_pte_ux;
        else begin
            if (r_req.store) perm_ok = is_pte_uw;
            else if (csr_ptw_comm_i.mstatus.mxr) perm_ok = is_pte_ur || is_pte_ux;
            else perm_ok = is_pte_ur;
        end
    end
end

// dmem Request
always_comb begin
    pte_wdata = '0;
    pte_wdata.a = 1'b1;
end

assign ptw_dmem_comm_o.req.phys = 1'b1;
assign ptw_dmem_comm_o.req.cmd = M_XRD;
assign ptw_dmem_comm_o.req.typ = MT_D;
assign ptw_dmem_comm_o.req.addr = pte_addr;
assign ptw_dmem_comm_o.req.kill = 1'b0;
assign ptw_dmem_comm_o.req.data = { '0,
                                    pte_wdata.ppn, 
                                    pte_wdata.rfs, 
                                    pte_wdata.d,
                                    pte_wdata.a,
                                    pte_wdata.g,
                                    pte_wdata.u,
                                    pte_wdata.x,
                                    pte_wdata.w,
                                    pte_wdata.r,
                                    pte_wdata.v
                                    };

// TLB Response
assign resp_err = (current_state == S_ERROR);
assign resp_val = (current_state == S_DONE) || resp_err;

assign r_resp_ppn = {'0, pte_addr[SIZE_VADDR-1:12]}; // pte_addr >> 12
//assign r_resp_ppn = {{(64-(SIZE_VADDR-12)){1'b0}}, pte_addr[SIZE_VADDR-1:12]}; // pte_addr >> 12
genvar j;
generate
    for (j = 0; j < (LEVELS-1); j++) begin
        logic [63:0] aux_resp_ppn_lvl;
        assign aux_resp_ppn_lvl = {'0, {r_resp_ppn[63:(LEVELS-j-1)*PAGE_LVL_BITS], r_req.vpn[PAGE_LVL_BITS*(LEVELS-j-1)-1:0]}};
        assign resp_ppn_lvl[j] = aux_resp_ppn_lvl[PPN_SIZE-1:0];
    end
endgenerate
assign resp_ppn_lvl[LEVELS-1] = r_resp_ppn[PPN_SIZE-1:0];
assign resp_ppn = resp_ppn_lvl[count_q];

// Send TLB Response to Arb
assign ptw_tlb_comm.resp.valid = resp_val;
assign ptw_tlb_comm.resp.error = resp_err;
assign ptw_tlb_comm.resp.level = count_q;
assign ptw_tlb_comm.resp.pte.ppn = resp_ppn;
assign ptw_tlb_comm.resp.pte.rfs = r_pte.rfs;
assign ptw_tlb_comm.resp.pte.d = r_pte.d;
assign ptw_tlb_comm.resp.pte.a = r_pte.a;
assign ptw_tlb_comm.resp.pte.g = r_pte.g;
assign ptw_tlb_comm.resp.pte.u = r_pte.u;
assign ptw_tlb_comm.resp.pte.x = r_pte.x;
assign ptw_tlb_comm.resp.pte.w = r_pte.w;
assign ptw_tlb_comm.resp.pte.r = r_pte.r;
assign ptw_tlb_comm.resp.pte.v = r_pte.v;
assign ptw_tlb_comm.ptw_ready = ptw_ready;
assign ptw_tlb_comm.ptw_status = csr_ptw_comm_i.mstatus;
assign ptw_tlb_comm.invalidate_tlb = csr_ptw_comm_i.flush;

// Page-Table Walker FSM 
always_ff @(posedge clk_i, negedge rstn_i) begin
    if (!rstn_i) begin
        current_state <= S_READY;
        count_q <= '0;
    end
    else begin
        current_state <= next_state;
        count_q <= count_d;
    end
end

always_comb begin
    count_d = count_q;
    count = count_q + 1'b1;
    pmu_ptw_hit_o = 1'b0;
    pmu_ptw_miss_o = 1'b0;
    ptw_dmem_comm_o.req.valid = 1'b0;
    next_state = current_state;
    case (current_state)
        S_READY : begin
            count_d = '0;
            if (tlb_ptw_comm.req.valid) next_state = S_REQ;
            else next_state = S_READY;
        end
        S_REQ : begin
            ptw_dmem_comm_o.req.valid = 1'b1;
            if (pte_cache_hit && (count_q < (LEVELS-1))) begin
                ptw_dmem_comm_o.req.valid = 1'b0;
                pmu_ptw_hit_o = 1'b1;
                count_d = count[1:0];
                next_state = S_REQ;
            end else if (dmem_ptw_comm_i.dmem_ready) begin
                next_state = S_WAIT;
            end else begin
                next_state = S_REQ;
            end
        end
        S_WAIT : begin
            if (dmem_ptw_comm_i.resp.nack) begin
                next_state = S_REQ;
            end else if (dmem_ptw_comm_i.resp.valid) begin
                if (invalid_pte) begin
                    next_state = S_ERROR;
                end else if (is_pte_table && (count_q < (LEVELS-1))) begin
                    count_d = count[1:0];
                    pmu_ptw_miss_o = 1'b1;
                    next_state = S_REQ;
                end else if (is_pte_leaf) begin
                    next_state = S_DONE;
                end 
                else begin
                    next_state = S_ERROR;
                end
            end
            else begin 
                next_state = S_WAIT;
            end
        end
        S_DONE : begin
            next_state = S_READY;
        end
        S_ERROR : begin
            next_state = S_READY;
        end
    endcase
end

endmodule

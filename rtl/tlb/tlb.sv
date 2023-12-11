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

/* TLB follows SV39 specification*/

module tlb 
import mmu_pkg::*;
#(
)(
    input logic clk_i,                          // System clock signal.
    input logic rstn_i,                         // System reset signal (active low).

    // TLB request-response
    input cache_tlb_comm_t cache_tlb_comm_i,    // Communication from translation requester to TLB.
    output tlb_cache_comm_t tlb_cache_comm_o,   // Communication from TLB to translation requester.

    // PTW request-respone
    input ptw_tlb_comm_t ptw_tlb_comm_i,        // Communication from TLB to PTW.
    output tlb_ptw_comm_t tlb_ptw_comm_o,       // Communication from to PTW to TLB.

    // PMU counter events
    output logic pmu_tlb_access_o,              // Accepted Translation request to TLB. 
    output logic pmu_tlb_miss_o                 // Accepted Translation request to TLB misses. 
);

tlb_entry_t [TLB_ENTRIES-1:0] tlb_entries;

// TLB WRITE LOGIC
///////////////////////////////

logic clear_tlb, write_tlb;
logic [TLB_ENTRIES-1:0] clear_mask;
logic [TLB_IDX_SIZE-1:0] write_idx;

assign write_idx = tlb_req_tmp.write_idx; // stored write_idx with the eviction idx (calculated in the first cycle of the req)
always_ff @(posedge clk_i, negedge rstn_i) begin
    if(~rstn_i) begin
		for (int i=0; i<TLB_ENTRIES; ++i) begin
            tlb_entries[i] <= '0;
        end
    end else begin
        if (clear_tlb) begin
            for (int i=0; i<TLB_ENTRIES; ++i) begin
                if (clear_mask[i]) tlb_entries[i] <= '0;
            end
        end else if (write_tlb) begin
            tlb_entries[write_idx].vpn <= tlb_req_tmp.vpn;
            tlb_entries[write_idx].asid <= tlb_req_tmp.asid;
            tlb_entries[write_idx].ppn <= ptw_tlb_comm_i.resp.pte.ppn;
            tlb_entries[write_idx].level <= ptw_tlb_comm_i.resp.level;
            tlb_entries[write_idx].dirty <= ptw_tlb_comm_i.resp.pte.d;
            tlb_entries[write_idx].perms.ur <= ptw_tlb_comm_i.resp.pte.r & ptw_tlb_comm_i.resp.pte.u & ptw_tlb_comm_i.resp.pte.v; // this is slightly different
            tlb_entries[write_idx].perms.uw <= ptw_tlb_comm_i.resp.pte.w & ptw_tlb_comm_i.resp.pte.u & ptw_tlb_comm_i.resp.pte.v;
            tlb_entries[write_idx].perms.ux <= ptw_tlb_comm_i.resp.pte.x & ptw_tlb_comm_i.resp.pte.u & ptw_tlb_comm_i.resp.pte.v;
            tlb_entries[write_idx].perms.sr <= ptw_tlb_comm_i.resp.pte.r & !ptw_tlb_comm_i.resp.pte.u & ptw_tlb_comm_i.resp.pte.v;
            tlb_entries[write_idx].perms.sw <= ptw_tlb_comm_i.resp.pte.w & !ptw_tlb_comm_i.resp.pte.u & ptw_tlb_comm_i.resp.pte.v;
            tlb_entries[write_idx].perms.sx <= ptw_tlb_comm_i.resp.pte.x & !ptw_tlb_comm_i.resp.pte.u & ptw_tlb_comm_i.resp.pte.v;
            tlb_entries[write_idx].valid <= !ptw_tlb_comm_i.resp.error;
            tlb_entries[write_idx].nempty <= 1'b1;
        end
    end
end

// CAM, TLB READ LOGIC
///////////////////////////////

logic [TLB_ENTRIES-1:0] hits_g, hits_m, hits_k, hits_cam;
logic hit_g, hit_m, hit_k, hit_cam;
logic [TLB_IDX_SIZE-1:0] hit_idx;

logic [VPN_SIZE:0] cache_vpn;
assign cache_vpn = cache_tlb_comm_i.req.vpn;
logic [ASID_SIZE-1:0] cache_asid;
assign cache_asid = cache_tlb_comm_i.req.asid;

always_comb begin
    int i;
    for (i = 0; i < TLB_ENTRIES; i++) begin
        hits_g[i] = (tlb_entries[i].vpn[26:18] == cache_vpn[26:18] && tlb_entries[i].asid == cache_asid && tlb_entries[i].nempty && tlb_entries[i].level == GIGA_PAGE) ? 1'b1 : 1'b0;
        hits_m[i] = (tlb_entries[i].vpn[26:9] == cache_vpn[26:9] && tlb_entries[i].asid == cache_asid && tlb_entries[i].nempty && tlb_entries[i].level == MEGA_PAGE) ? 1'b1 : 1'b0;
        hits_k[i] = (tlb_entries[i].vpn == cache_vpn[26:0] && tlb_entries[i].asid == cache_asid && tlb_entries[i].nempty && tlb_entries[i].level == KILO_PAGE) ? 1'b1 : 1'b0;
    end
end
assign hits_cam = hits_g | hits_m | hits_k; // at maximun, only one element of the hits_cam array will have a 1
assign hit_k = |hits_k;
assign hit_m = |hits_m;
assign hit_g = |hits_g;
assign hit_cam = |hits_cam;

// encodes the hit index
always_comb begin
	hit_idx = '0; // don't care if no 'in' bits set
	for (int i = 0; i < TLB_ENTRIES; i++) begin
		if (hits_cam[i]==1'b1) begin
			hit_idx = i;
            break;
		end
	end
end

// HIT LOGIC
///////////////////////////////

logic bad_va, tlb_hit, tlb_miss, store_hit, vm_enable, passthrough;

logic read_ok, write_ok, exec_ok, sv_priv_lvl; // value chagned by permission checking logic

assign vm_enable = cache_tlb_comm_i.vm_enable;
assign passthrough = cache_tlb_comm_i.req.passthrough;

assign bad_va = (vm_enable && (cache_vpn[VPN_SIZE] != cache_vpn[VPN_SIZE-1])) ? 1'b1 : 1'b0;
assign tlb_hit = vm_enable && hit_cam && store_hit;
assign tlb_miss = vm_enable && !(hit_cam && store_hit) && !bad_va;

// This logic solves the problem of a store hitting in TLB a page not marked as dirty
always_comb begin
    if (cache_tlb_comm_i.req.store) begin
        if(tlb_entries[hit_idx].dirty) begin // dirty page, no problem
            store_hit = 1'b1;
        end else if (!write_ok) begin // we dont have write perms, so hit in order to raise STORE xcpt
            store_hit = 1'b1;
        end else begin // we have the right permissions, but the page is not set as dirty, we have to mark it as so in the PT
            store_hit = 1'b0;
        end     
    end else begin // not a store, no problem
        store_hit = 1'b1;
    end
end

// EVICTION MECHANISM
///////////////////////////////
logic has_invalid_entry, access_hit;
logic [TLB_IDX_SIZE-1:0] eviction_idx, invalid_idx, plru_eviction_idx;

assign access_hit = tlb_hit & cache_tlb_comm_i.req.valid;

pseudoLRU #(.ENTRIES(TLB_ENTRIES)) tlb_PLRU (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .access_hit_i(access_hit),
    .access_idx_i(hit_idx),
    .replacement_idx_o(plru_eviction_idx)
);


/* 
// RANDOM EVICTION
always_ff @(posedge clk_i, negedge rstn_i) begin
    if(~rstn_i) begin
		random_eviction_idx <= '0;
    end else begin
		random_eviction_idx <= random_eviction_idx + 1'b1;
    end
end
*/

// Detect and identify if and entry is not being used
always_comb begin
    invalid_idx = '0;
    has_invalid_entry = ~tlb_entries[invalid_idx].nempty;
    while (!has_invalid_entry && invalid_idx != (TLB_ENTRIES-1)) begin
      invalid_idx += 1'b1;
      has_invalid_entry = ~tlb_entries[invalid_idx].nempty;
    end
end

assign eviction_idx = has_invalid_entry ? invalid_idx : plru_eviction_idx;

// FLUSH LOGIC
///////////////////////////////

logic clean_tlb; // TLB FSM changes this value

always_comb begin
    clear_tlb = 1'b0;
    clear_mask = '0;
    if (ptw_tlb_comm_i.invalidate_tlb) begin 
        clear_tlb = 1'b1;
        clear_mask = 'hFF;
    end else if (clean_tlb) begin // flush invalid entries and cam hit in a non-dirty page when store arrives
        clear_tlb = 1'b1;
        for (int i=0; i<TLB_ENTRIES; ++i) begin
            if (!tlb_entries[i].valid || (i == hit_idx && hit_cam && !store_hit)) begin
                clear_mask[i] = 1'b1; // invalidate the TLB entry because we do not have dirty bit on it and is required or entry is invalid
            end 
        end
    end
end

// TLB FSM, in case of TLB miss 
///////////////////////////////

typedef enum logic [1:0] {
    IDLE,
    SEND_REQUEST,
    WAIT_RESPONSE,
    INVALIDATED_WAIT_RESPONSE
} ptw_state;

ptw_state current_state, next_state;
logic store_tlb_req, send_tlb_req, tlb_ready;
logic pmu_tlb_access, pmu_tlb_miss;
tlb_req_tmp_storage_t tlb_req_tmp;

always_comb begin
    store_tlb_req = 1'b0;
    send_tlb_req = 1'b0;
    write_tlb = 1'b0;
    clean_tlb = 1'b0;
    tlb_ready = 1'b0;
    pmu_tlb_access = 1'b0;
    pmu_tlb_miss = 1'b0;
    next_state = current_state; // By default, we remain in the same state
    case (current_state)
        IDLE : begin
            tlb_ready = 1'b1;
            if (cache_tlb_comm_i.req.valid) begin // if we have a valid request always try to clean the tlb
                clean_tlb = 1'b1; // flush invalid pages, and not dirty page case
                pmu_tlb_access = 1'b1; // tlb access event for PMU
                if (tlb_miss) begin 
                    store_tlb_req = 1'b1; // store req to send it in the next state
                    pmu_tlb_miss = 1'b1; // tlb miss event for PMU
                    next_state = SEND_REQUEST;
                end
            end 
        end
        SEND_REQUEST : begin
            send_tlb_req = 1'b1; // send stored request to PTW
            if (!ptw_tlb_comm_i.ptw_ready && ptw_tlb_comm_i.invalidate_tlb) begin
                next_state = IDLE; // TLB request cancelled
            end else if (ptw_tlb_comm_i.ptw_ready) begin
                if (ptw_tlb_comm_i.invalidate_tlb) begin
                    next_state = INVALIDATED_WAIT_RESPONSE; 
                end else begin
                    next_state = WAIT_RESPONSE;    // go to waiting for response state
                end
            end 
        end
        WAIT_RESPONSE : begin
            if (ptw_tlb_comm_i.resp.valid) begin
                write_tlb = 1'b1;
                next_state = IDLE;
            end else if (ptw_tlb_comm_i.invalidate_tlb) begin
                next_state = INVALIDATED_WAIT_RESPONSE; 
            end
        end
        INVALIDATED_WAIT_RESPONSE : begin
            if (ptw_tlb_comm_i.resp.valid) begin
                next_state = IDLE;   // we catched the request in progress
            end
        end
    endcase
end

always_ff @(posedge clk_i, negedge rstn_i) begin
    if (!rstn_i) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always_ff @(posedge clk_i, negedge rstn_i) begin
    if (!rstn_i) begin
        tlb_req_tmp <= '0;
    end else if (store_tlb_req) begin
        tlb_req_tmp.vpn <= cache_tlb_comm_i.req.vpn[VPN_SIZE-1:0];
        tlb_req_tmp.asid <= cache_tlb_comm_i.req.asid;
        tlb_req_tmp.store <= cache_tlb_comm_i.req.store;
        tlb_req_tmp.fetch <= cache_tlb_comm_i.req.instruction;
        tlb_req_tmp.write_idx <= eviction_idx;
    end
end

// TLB-PTW send request
always_comb begin
    if (send_tlb_req) begin
        tlb_ptw_comm_o.req.valid = 1'b1;
        tlb_ptw_comm_o.req.vpn = tlb_req_tmp.vpn;
        tlb_ptw_comm_o.req.asid = tlb_req_tmp.asid;
        tlb_ptw_comm_o.req.prv = cache_tlb_comm_i.priv_lvl; // note that we send the current cycle prv lvl
        tlb_ptw_comm_o.req.store = tlb_req_tmp.store;
        tlb_ptw_comm_o.req.fetch = tlb_req_tmp.fetch;
    end else begin
        tlb_ptw_comm_o.req = '0;
    end
end




// PERMISSION CHECKING
///////////////////////////////

assign sv_priv_lvl = (cache_tlb_comm_i.priv_lvl != '0) ? 1'b1 : 1'b0; // if we are not user -> supervisor

// Read permission
always_comb begin
    if (sv_priv_lvl) begin
        if (ptw_tlb_comm_i.ptw_status.sum) begin // if SUM bit is set, in SV we can read in readable user pages
            if (ptw_tlb_comm_i.ptw_status.mxr) begin // if MXR bit is set, executable pages can be also readed
                read_ok = tlb_entries[hit_idx].perms.sr | tlb_entries[hit_idx].perms.ur | tlb_entries[hit_idx].perms.sx | tlb_entries[hit_idx].perms.ux;
            end else begin
                read_ok = tlb_entries[hit_idx].perms.sr | tlb_entries[hit_idx].perms.ur;
            end
        end else begin
            if (ptw_tlb_comm_i.ptw_status.mxr) begin // if MXR bit is set, executable pages can be also readed
                read_ok = tlb_entries[hit_idx].perms.sr | tlb_entries[hit_idx].perms.sx;
            end else begin
                read_ok = tlb_entries[hit_idx].perms.sr;
            end
        end
    end else begin // User mode
        if (ptw_tlb_comm_i.ptw_status.mxr) begin // if MXR bit is set, executable pages can be also readed
            read_ok = tlb_entries[hit_idx].perms.ur | tlb_entries[hit_idx].perms.ux;
        end else begin
            read_ok = tlb_entries[hit_idx].perms.ur;
        end
    end
end

// Write permission
always_comb begin
    if(sv_priv_lvl) begin
        if (ptw_tlb_comm_i.ptw_status.sum) begin // if SUM bit is set, in SV we can write in writable user pages
            write_ok = tlb_entries[hit_idx].perms.sw | tlb_entries[hit_idx].perms.uw;
        end else begin
            write_ok = tlb_entries[hit_idx].perms.sw;
        end
    end else begin
        write_ok = tlb_entries[hit_idx].perms.uw;
    end
end

// Execution permission
assign exec_ok = (sv_priv_lvl) ? tlb_entries[hit_idx].perms.sx : tlb_entries[hit_idx].perms.ux;

logic xcpt_if, xcpt_st, xcpt_ld;
assign xcpt_if = (bad_va || (tlb_hit && !exec_ok)) ? 1'b1 : 1'b0;
assign xcpt_st = (bad_va || (tlb_hit && !write_ok)) ? 1'b1 : 1'b0;
assign xcpt_ld = (bad_va || (tlb_hit && !read_ok)) ? 1'b1 : 1'b0;

// PPN ASSIGNAMENT
///////////////////////////////

logic [PPN_SIZE-1:0] ppn_k, ppn_m, ppn_g, ppn;

// We receive superpages from PTW as if they were 4KB pages (implementation decision in LowRisc)
// For example 2MB ppn 1 is encoded as 100000000b -> 512 in 4KB pages
// therefore, it is required exctracting the page number in its real size and fill the 0s with the 
// corresponding bits of the vpn to get the correct translation

assign ppn_k = tlb_entries[hit_idx].ppn;
assign ppn_m = {tlb_entries[hit_idx].ppn >> PAGE_LVL_BITS, cache_vpn[PAGE_LVL_BITS-1:0]};
assign ppn_g = {tlb_entries[hit_idx].ppn >> PAGE_LVL_BITS * 2, cache_vpn[PAGE_LVL_BITS*2-1:0]};

/*always_comb begin
    if(vm_enable && !passthrough) begin
        if (hit_k) begin
            ppn = ppn_k;
        end else if (hit_m) begin
            ppn = ppn_m;
        end else if (hit_g) begin
            ppn = ppn_g;
        end else begin
            ppn = '0;
        end
    end else begin 
        ppn[PPN_SIZE-1:VPN_SIZE] = '0;
        ppn[VPN_SIZE-1:0] = cache_vpn;
    end
end*/

// TLB RESPONSE
///////////////////////////////

assign tlb_cache_comm_o.tlb_ready = tlb_ready; 
assign tlb_cache_comm_o.resp.miss = tlb_miss;
assign tlb_cache_comm_o.resp.ppn =
    ((ppn_k & {PPN_SIZE{hit_k & vm_enable & ~passthrough}}) | (ppn_m & {PPN_SIZE{hit_m & vm_enable & ~passthrough}})) |
    ((ppn_g & {PPN_SIZE{hit_g & vm_enable & ~passthrough}}) | {{PPN_SIZE-VPN_SIZE{1'b0}}, cache_vpn & {PPN_SIZE{~(vm_enable & ~passthrough)}}});
assign tlb_cache_comm_o.resp.xcpt.load = xcpt_ld;
assign tlb_cache_comm_o.resp.xcpt.store = xcpt_st;
assign tlb_cache_comm_o.resp.xcpt.fetch = xcpt_if;

// PMU EVENTS
///////////////////////////////
assign pmu_tlb_access_o = pmu_tlb_access;
assign pmu_tlb_miss_o = pmu_tlb_miss;

endmodule

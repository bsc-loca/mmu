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

package mmu_pkg;

// SV39 Parameters
parameter VPN_SIZE = 27;
parameter PPN_SIZE = 44;
parameter SIZE_VADDR = 39;
parameter ASID_SIZE = 7;
parameter LEVELS = 3;
parameter PAGE_LVL_BITS = 9;
parameter PTESIZE = 8;

parameter TLB_ENTRIES = 8;
parameter TLB_IDX_SIZE = $clog2(TLB_ENTRIES);

parameter PTW_CACHE_SIZE = $clog2(LEVELS*2);

parameter [1:0] GIGA_PAGE = 2'b00;
parameter [1:0] MEGA_PAGE = 2'b01;
parameter [1:0] KILO_PAGE = 2'b10;

typedef struct packed {
    logic [PPN_SIZE-1:0] ppn; 
    logic [1:0] rfs;
    logic d;
    logic a;
    logic g;
    logic u;
    logic x;
    logic w;
    logic r;
    logic v;
} pte_t;

typedef struct packed {
    logic        sd    ;
    logic [26:0] zero5 ;
    logic [1:0]  sxl   ;
    logic [1:0]  uxl   ;
    logic [8:0]  zero4 ;
    logic        tsr   ;
    logic        tw    ;
    logic        tvm   ;
    logic        mxr   ;
    logic        sum   ;
    logic        mprv  ;
    logic [1:0]  xs    ;
    logic [1:0]  fs    ;
    logic [1:0]  mpp   ;
    logic [1:0]  zero3 ;
    logic        spp   ;  
    logic        mpie  ;
    logic        zero2 ;
    logic        spie  ;
    logic        upie  ;
    logic        mie   ;
    logic        zero1 ;
    logic        sie   ;
    logic        uie   ;
} csr_mstatus_t;

////////////////////////////////      
//
//  Cache-TLB communication
//
///////////////////////////////   

// Cache-TLB request
typedef struct packed {
    logic valid;   
    logic [ASID_SIZE-1:0] asid;
    logic [VPN_SIZE:0] vpn;
    logic passthrough;
    logic instruction;
    logic store;
} cache_tlb_req_t;

typedef struct packed {
    cache_tlb_req_t req;
    logic [1:0] priv_lvl;   
    logic vm_enable; 
} cache_tlb_comm_t;

typedef struct packed {
    logic load;
    logic store;
    logic fetch;
} tlb_ex_t;

// TLB-Cache response
typedef struct packed { 
    logic miss;
    logic [PPN_SIZE-1:0] ppn; 
    tlb_ex_t xcpt;
    logic [7:0] hit_idx;
} tlb_cache_resp_t;

typedef struct packed {
    logic tlb_ready;  
    tlb_cache_resp_t resp;
} tlb_cache_comm_t;

////////////////////////////////      
//
//  TLB-PTW communication
//
///////////////////////////////

// TLB-PTW request
typedef struct packed {
    logic valid;
    logic [VPN_SIZE-1:0] vpn;
    logic [ASID_SIZE-1:0] asid;   
    logic [1:0] prv;
    logic store;
    logic fetch;
} tlb_ptw_req_t;

typedef struct packed {
    tlb_ptw_req_t req;
} tlb_ptw_comm_t;

// PTW-TLB response
typedef struct packed {
    logic valid;
    logic error;
    pte_t pte;
    logic [$clog2(LEVELS)-1:0] level;
} ptw_tlb_resp_t;

typedef struct packed {
    ptw_tlb_resp_t resp;
    logic ptw_ready;
    csr_mstatus_t ptw_status; 
    logic invalidate_tlb;
} ptw_tlb_comm_t;

////////////////////////////////      
//
//  TLB
//
///////////////////////////////

typedef struct packed {
    logic ur;
    logic uw;  
    logic ux;
    logic sr;
    logic sw;  
    logic sx;  
} tlb_entry_permissions_t;

typedef struct packed {
    logic [VPN_SIZE-1:0] vpn;
    logic [ASID_SIZE-1:0] asid;
    logic [PPN_SIZE-1:0] ppn;
    logic [1:0] level;
    logic dirty;
    tlb_entry_permissions_t perms;
    logic valid;
    logic nempty;
} tlb_entry_t;

typedef struct packed {
    logic [VPN_SIZE-1:0] vpn;
    logic [ASID_SIZE-1:0] asid;
    logic store;
    logic fetch;
    logic [TLB_IDX_SIZE-1:0] write_idx;
} tlb_req_tmp_storage_t;

////////////////////////////////      
//
//  PTW
//
///////////////////////////////
//
typedef struct packed {
    logic valid;
    logic [SIZE_VADDR:0] tags;
    logic [PPN_SIZE-1:0] data;
} ptw_ptecache_entry_t;

////////////////////////////////      
//
//  PTW Communications
//
///////////////////////////////

// PTW-DMEM request
typedef struct packed {
    logic                valid  ;
    logic [SIZE_VADDR:0] addr   ;
    logic [4:0]          cmd    ;
    logic [3:0]          typ    ;
    logic                kill   ;
    logic                phys   ;
    logic [63:0]         data   ;
} ptw_dmem_req_t;

typedef struct packed {
    ptw_dmem_req_t req;
} ptw_dmem_comm_t;

// PTW-DMEM response
typedef struct packed {
    logic        valid        ;
    logic [SIZE_VADDR:0] addr         ;
    logic [7:0]  tag_addr     ;
    logic [4:0]  cmd          ;
    logic [3:0]  typ          ;
    logic [63:0] data        ;
    logic        nack         ;
    logic        replay       ;
    logic        has_data     ;
    logic [63:0] data_subw    ;
    logic [63:0] store_data   ;
    logic        rnvalid      ;
    logic [7:0]  rnext        ;
    logic        xcpt_ma_ld   ;
    logic        xcpt_ma_st   ;
    logic        xcpt_pf_ld   ;
    logic        xcpt_pf_st   ;
    logic        ordered      ;
} dmem_ptw_resp_t;

typedef struct packed {
    logic dmem_ready;
    dmem_ptw_resp_t resp;
} dmem_ptw_comm_t;

// CSR interface

typedef struct packed {
    logic [63:0] satp;
    logic flush;
    csr_mstatus_t mstatus;
} csr_ptw_comm_t;

endpackage

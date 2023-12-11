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

parameter [1:0] GIGA_PAGE = 2'b00;  // 1 GiB Page
parameter [1:0] MEGA_PAGE = 2'b01;  // 2 MiB Page
parameter [1:0] KILO_PAGE = 2'b10;  // 4 KiB Page

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
    logic                 valid;        // Translation request valid.
    logic [ASID_SIZE-1:0] asid;         // Address space identifier.
    logic [VPN_SIZE:0]    vpn;          // Virtual page number.
    logic                 passthrough;  // Virtual address directly corresponds to physical address, for direct assignment between a virtual machine and the physical device.
    logic                 instruction;  // The translation request is for a instruction fetch address.
    logic                 store;        // The translation request is for a store address.
} cache_tlb_req_t;                      // Translation request.

typedef struct packed {
    cache_tlb_req_t req;            // Translation request.
    logic [1:0]     priv_lvl;       // Privilege level of the translation: 2'b00 (User), 2'b01 (Supervisor), 2'b11 (Machine).
    logic           vm_enable;      // Memory virtualization is active.
} cache_tlb_comm_t;                 // Communication from translation requester to TLB.

typedef struct packed {
    logic load;                     // Load operation.
    logic store;                    // Store operation.
    logic fetch;                    // Fetch operation.
} tlb_ex_t;                         // Exception origin.

// TLB-Cache response
typedef struct packed { 
    logic                miss;      // If the translation request missed set to 1 Otherwise, the rest of the signals have valid information of the response.
    logic [PPN_SIZE-1:0] ppn;       // Physical page number.
    tlb_ex_t             xcpt;      // Exceptions produced by the requests.
    logic [7:0]          hit_idx;   // CAM hit index of the translation request.
} tlb_cache_resp_t;                 // Translation response.

typedef struct packed {
    logic            tlb_ready;     // The tlb is ready to accept a translation request. If 0 it shouldn't receive any translation request.
    tlb_cache_resp_t resp;          // Translation response.
} tlb_cache_comm_t;                 // Communication from TLB to translation requester.

////////////////////////////////      
//
//  TLB-PTW communication
//
///////////////////////////////

// TLB-PTW request
typedef struct packed {
    logic                 valid;    // Translation request valid.
    logic [VPN_SIZE-1:0]  vpn;      // Virtual page number.
    logic [ASID_SIZE-1:0] asid;     // Address space identifier. 
    logic [1:0]           prv;      // Privilege level of the translation: 2'b00 (User), 2'b01 (Supervisor), 2'b11 (Machine).
    logic                 store;    // Store operation.               
    logic                 fetch;    // Fetch operation.
} tlb_ptw_req_t;                    // Translation request of the TLB to the PTW.

typedef struct packed {
    tlb_ptw_req_t req;              // Translation request of the TLB to the PTW.
} tlb_ptw_comm_t;                   // Communication from TLB to PTW.

// PTW-TLB response
typedef struct packed {
    logic                      valid; // Translation response valid.
    logic                      error; // An error has ocurred with the translation request. Only check if the response is valid.
    pte_t                      pte;   // Page table entry.
    logic [$clog2(LEVELS)-1:0] level; // Privilege level of the translation.
} ptw_tlb_resp_t;                     // PTW response to TLB translation request.

typedef struct packed {
    ptw_tlb_resp_t resp;            // PTW response to TLB translation request.
    logic          ptw_ready;       // PTW is ready to receive a translation request.
    csr_mstatus_t  ptw_status;      // mstatus csr register value, sent through the ptw.    
    logic          invalidate_tlb;  // Signal to flush all entries in TLB and don't allocate in-progress transactions with the PTW.
} ptw_tlb_comm_t;                   // Communication from to PTW to TLB.

////////////////////////////////      
//
//  TLB
//
///////////////////////////////

typedef struct packed {
    logic ur;               // User read permission.
    logic uw;               // User write permission.
    logic ux;               // User execute permission.
    logic sr;               // Supervisor read permission.
    logic sw;               // Supervisor write permission.
    logic sx;               // Supervisor execute permission.
} tlb_entry_permissions_t;  // TLB page entry permissions.

typedef struct packed {
    logic [VPN_SIZE-1:0]    vpn;    // Virtual page number.
    logic [ASID_SIZE-1:0]   asid;   // Address space identifier.
    logic [PPN_SIZE-1:0]    ppn;    // Physical page number.
    logic [1:0]             level;  // Page entry size: 2'b00 (1 GiB Page), 2'b01 (2 MiB Page), 2'b10 (4 KiB Page).
    logic                   dirty;  // The page entry is set as dirty.
    tlb_entry_permissions_t perms;  // TLB page entry permissions
    logic                   valid;  // The tlb entry is valid, set to 1 when the PTW sends a translation response without errors.
    logic                   nempty; // The tlb entry is not empty, when the PTW sends a translation response that we don't have to ignore, it is set to 1.
} tlb_entry_t;                      // TLB page entry.

typedef struct packed {
    logic [VPN_SIZE-1:0]        vpn;        // Virtual page number.
    logic [ASID_SIZE-1:0]       asid;       // Address space identifier.
    logic                       store;      // Store operation.
    logic                       fetch;      // Fetch operation.
    logic [TLB_IDX_SIZE-1:0]    write_idx;  // Index where the page requested to the PTW will be stored in the TLB's CAM. 
} tlb_req_tmp_storage_t;                    // Stored information of the translation request saved on a miss.

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

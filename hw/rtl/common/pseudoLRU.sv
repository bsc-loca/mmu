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

module pseudoLRU #(
      parameter int unsigned ENTRIES = 8
  )(
    input logic clk_i,
    input logic rstn_i,

    input logic access_hit_i, // only update the PLRU when there is a hit in the storage mechanism
    input logic [$clog2(ENTRIES)-1:0] access_idx_i,
    output logic [$clog2(ENTRIES)-1:0] replacement_idx_o
);

// Decode access_idx
logic [ENTRIES-1:0] access_array;
logic found;
logic found2;

logic [ENTRIES-1:0] replace_en;

function logic [$clog2(ENTRIES)-1:0] cast_integer(input [31:0] iter);
    cast_integer = iter[$clog2(ENTRIES)-1:0];
endfunction

always_comb begin
    access_array = '0; // don't care if no 'in' bits set
    found = 0;
    for (int unsigned i = 0; (i < ENTRIES) && (!found); i++) begin
        if (i == access_idx_i) begin
            access_array[i] = 1'b1;
            found = 1;
        end
    end
end


// -----------------------------------------------
// PLRU - Pseudo Least Recently Used Replacement
// -----------------------------------------------
logic [2*(ENTRIES-1)-1:0] plru_tree_q, plru_tree_d;
always_comb begin : plru_replacement
    plru_tree_d = plru_tree_q;
    // The PLRU-tree indexing:
    // lvl0        0
    //            / \
    //           /   \
    // lvl1     1     2
    //         / \   / \
    // lvl2   3   4 5   6
    //       / \ /\/\  /\
    //      ... ... ... ...
    // Just predefine which nodes will be set/cleared
    // E.g. for a TLB with 8 entries, the for-loop is semantically
    // equivalent to the following pseudo-code:
    // unique case (1'b1)
    // lu_hit[7]: plru_tree_d[0, 2, 6] = {1, 1, 1};
    // lu_hit[6]: plru_tree_d[0, 2, 6] = {1, 1, 0};
    // lu_hit[5]: plru_tree_d[0, 2, 5] = {1, 0, 1};
    // lu_hit[4]: plru_tree_d[0, 2, 5] = {1, 0, 0};
    // lu_hit[3]: plru_tree_d[0, 1, 4] = {0, 1, 1};
    // lu_hit[2]: plru_tree_d[0, 1, 4] = {0, 1, 0};
    // lu_hit[1]: plru_tree_d[0, 1, 3] = {0, 0, 1};
    // lu_hit[0]: plru_tree_d[0, 1, 3] = {0, 0, 0};
    // default: begin /* No hit */ end
    // endcase
    for (int unsigned i = 0; i < ENTRIES; i++) begin
        automatic int unsigned idx_base = 0;
        automatic int unsigned shift = 0;
        automatic logic [31:0] new_index = '0;
        // we got a hit so update the pointer as it was least recently used
        if (access_array[i] & access_hit_i) begin
            // Set the nodes to the values we would expect
            for (int unsigned lvl = 0; lvl < $unsigned($clog2(ENTRIES)); lvl++) begin
                idx_base = $unsigned((2**lvl)-1);
                // lvl0 <=> MSB, lvl1 <=> MSB-1, ...
                shift = $unsigned($clog2(ENTRIES)) - lvl;
                // to circumvent the 32 bit integer arithmetic assignment
                new_index =  ~((i >> (shift-1)) & 32'b1);
                plru_tree_d[idx_base + (i >> shift)] = new_index[0];
            end
        end
    end
    // Decode tree to write enable signals
    // Next for-loop basically creates the following logic for e.g. an 8 entry
    // TLB (note: pseudo-code obviously):
    // replace_en[7] = &plru_tree_q[ 6, 2, 0]; //plru_tree_q[0,2,6]=={1,1,1}
    // replace_en[6] = &plru_tree_q[~6, 2, 0]; //plru_tree_q[0,2,6]=={1,1,0}
    // replace_en[5] = &plru_tree_q[ 5,~2, 0]; //plru_tree_q[0,2,5]=={1,0,1}
    // replace_en[4] = &plru_tree_q[~5,~2, 0]; //plru_tree_q[0,2,5]=={1,0,0}
    // replace_en[3] = &plru_tree_q[ 4, 1,~0]; //plru_tree_q[0,1,4]=={0,1,1}
    // replace_en[2] = &plru_tree_q[~4, 1,~0]; //plru_tree_q[0,1,4]=={0,1,0}
    // replace_en[1] = &plru_tree_q[ 3,~1,~0]; //plru_tree_q[0,1,3]=={0,0,1}
    // replace_en[0] = &plru_tree_q[~3,~1,~0]; //plru_tree_q[0,1,3]=={0,0,0}
    // For each entry traverse the tree. If every tree-node matches,
    // the corresponding bit of the entry's index, this is
    // the next entry to replace.
    for (int unsigned i = 0; i < ENTRIES; i += 1) begin
        automatic logic en = 1'b1;
        automatic logic [31:0] new_index2 = '0;
        automatic int unsigned idx_base, shift;
        for (int unsigned lvl = 0; lvl < $unsigned($clog2(ENTRIES)); lvl++) begin
            idx_base = $unsigned((2**lvl)-1);
            // lvl0 <=> MSB, lvl1 <=> MSB-1, ...
            shift = $unsigned($clog2(ENTRIES)) - lvl;

            // en &= plru_tree_q[idx_base + (i>>shift)] == ((i >> (shift-1)) & 1'b1);
            new_index2 =  (i >> (shift-1)) & 32'b1;
            if (new_index2[0]) begin
                en &= plru_tree_q[idx_base + (i>>shift)];
            end else begin
                en &= ~plru_tree_q[idx_base + (i>>shift)];
            end
        end
        replace_en[i] = en;
    end
end

// sequential process
always_ff @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        plru_tree_q <= '0;
    end else begin
        plru_tree_q <= plru_tree_d;
    end
end

// Encode replace_en
always_comb begin
    replacement_idx_o = '0; // don't care if no 'in' bits set
    found2 = 1'b0;
    for (int unsigned iter = 0; (iter < $unsigned(ENTRIES)) && (!found2); iter++) begin
        if (replace_en[iter] == 1'b1) begin
            replacement_idx_o = cast_integer(iter);
            found2 = 1'b1;
        end
    end
end


endmodule
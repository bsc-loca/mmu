/* * ---------------------------------------------------------
* Project Name   : DRAC
* File           : ptw_arb.sv
* Organization   : Barcelona Supercomputing Center
* Author(s)      : Xavier Carril Gil 
*                : Javier Salamero Sanz
* Email(s)       : xavier.carril@bsc.es
*                : javier.salamero@bsc.es
* References     :
* ------------------------------------------------------------
* Revision History
*  Revision   | Author     | Commit | Description
* ------------------------------------------------------------
*/

import mmu_pkg::*;

module ptw_arb #(
)(
    input logic clk_i,
    input logic rstn_i,

    // iTLB & dTLB interfaces
    input tlb_ptw_comm_t itlb_ptw_comm_i, 
    input tlb_ptw_comm_t dtlb_ptw_comm_i,
    output ptw_tlb_comm_t ptw_itlb_comm_o, 
    output ptw_tlb_comm_t ptw_dtlb_comm_o,

    // PTW interface
    input ptw_tlb_comm_t ptw_tlb_comm_i,
    output tlb_ptw_comm_t tlb_ptw_comm_o
);

logic is_req_waiting_d, is_req_waiting_q;
tlb_ptw_comm_t itlb_req_waiting_d, itlb_req_waiting_q;

typedef enum logic [1:0] {
    IDLE,
    SERVING_iTLB,
    SERVING_dTLB
} arbptw_state;

arbptw_state current_state, next_state;
always_ff @(posedge clk_i, negedge rstn_i) begin
    if (!rstn_i) begin
        current_state <= IDLE;
        is_req_waiting_q <= 1'b0;
        itlb_req_waiting_q <= '0;
    end
    else begin
        current_state <= next_state;
        is_req_waiting_q <= is_req_waiting_d;
        itlb_req_waiting_q <= itlb_req_waiting_d;
    end
end

always_comb begin
    is_req_waiting_d = is_req_waiting_q;
    itlb_req_waiting_d = itlb_req_waiting_q;
    ptw_itlb_comm_o.ptw_ready = 1'b0;
    ptw_dtlb_comm_o.ptw_ready = 1'b0;
    ptw_itlb_comm_o.ptw_status = ptw_tlb_comm_i.ptw_status;
    ptw_itlb_comm_o.invalidate_tlb = ptw_tlb_comm_i.invalidate_tlb;
    ptw_dtlb_comm_o.ptw_status = ptw_tlb_comm_i.ptw_status;
    ptw_dtlb_comm_o.invalidate_tlb = ptw_tlb_comm_i.invalidate_tlb;

    case (current_state)
        IDLE : begin
            ptw_itlb_comm_o.resp = '0;
            ptw_dtlb_comm_o.resp = '0;
            ptw_itlb_comm_o.ptw_ready = 1'b1;
            ptw_dtlb_comm_o.ptw_ready = 1'b1;
            if (dtlb_ptw_comm_i.req.valid && itlb_ptw_comm_i.req.valid) begin
                is_req_waiting_d = 1'b1;
                itlb_req_waiting_d = itlb_ptw_comm_i;
                tlb_ptw_comm_o = dtlb_ptw_comm_i;
                next_state = SERVING_dTLB;
            end else if (is_req_waiting_q) begin
                ptw_itlb_comm_o.ptw_ready = 1'b0;
                ptw_dtlb_comm_o.ptw_ready = 1'b0;
                next_state = SERVING_iTLB;
            end else if (dtlb_ptw_comm_i.req.valid) begin
                tlb_ptw_comm_o = dtlb_ptw_comm_i;
                next_state = SERVING_dTLB;
            end else if (itlb_ptw_comm_i.req.valid) begin
                tlb_ptw_comm_o = itlb_ptw_comm_i;
                next_state = SERVING_iTLB;
            end else begin
                tlb_ptw_comm_o = '0;
                next_state = IDLE;
            end
        end
        SERVING_iTLB : begin
            ptw_itlb_comm_o.resp = ptw_tlb_comm_i.resp;
            ptw_dtlb_comm_o.resp = '0;
            tlb_ptw_comm_o = (is_req_waiting_q) ? itlb_req_waiting_q : itlb_ptw_comm_i;
            if (!ptw_tlb_comm_i.resp.valid) begin
                next_state = SERVING_iTLB;
            end else begin
                next_state = IDLE;
                is_req_waiting_d = 1'b0;
            end
        end
        SERVING_dTLB : begin
            ptw_itlb_comm_o.resp = '0;
            ptw_dtlb_comm_o.resp = ptw_tlb_comm_i.resp;
            tlb_ptw_comm_o = dtlb_ptw_comm_i;
            if (!ptw_tlb_comm_i.resp.valid) begin
                next_state = SERVING_dTLB;
            end else begin
                next_state = IDLE;
            end
        end
    endcase
end

endmodule

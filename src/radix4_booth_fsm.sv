//Description: radixn_booth_multiplier control path
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 26/09/2021
//Parameters:

module radix4_booth_fsm(
    input  logic clk,
    input  logic en,
    input  logic start,
    input  logic rst_n,
    input  logic done_cntr,
    output logic start_booth,
    output logic en_booth,
    output logic rst_cntr_n,
    output logic done
);

typedef enum logic [1:0] {
    IDLE_S  = 2'b00,
    START_S = 2'b01,
    MUL_S   = 2'b10,
    DONE_S  = 2'b11 
} state_t;

state_t state, next_state;
logic done_rst_n;
logic done_rst_n_rst;
logic assert_done;

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE_S;
    end else if (en) begin
        state <= next_state;
    end
end

always_comb begin
    case(state)
        IDLE_S: begin
            next_state = (start) ? START_S : IDLE_S;
        end
        START_S: begin 
            next_state = MUL_S;
        end
        MUL_S: begin
            next_state = (done) ? DONE_S : MUL_S;
        end
        DONE_S: begin
            next_state = (start) ? START_S : IDLE_S;
        end
    endcase
end

always_comb begin
    case(state)
        IDLE_S: begin
            done_rst_n  = 1'b1;
            assert_done = 1'b0; 
            en_booth    = 1'b0;
            start_booth = 1'b0;
            rst_cntr_n  = 1'b0;
        end
        START_S: begin
            done_rst_n  = 1'b0;
            assert_done = 1'b0; 
            en_booth    = 1'b0;
            start_booth = 1'b1;
            rst_cntr_n  = 1'b0;
        end
        MUL_S: begin
            done_rst_n  = 1'b1;
            assert_done = 1'b0;
            en_booth    = ~done_cntr;
            start_booth = 1'b0;
            rst_cntr_n  = 1'b1;
        end
        DONE_S: begin
            done_rst_n  = 1'b1;
            assert_done = 1'b1;
            en_booth    = 1'b0; 
            start_booth = 1'b0;
            rst_cntr_n  = 1'b0;
        end
    endcase
end

assign done_rst_n_rst = rst_n & done_rst_n;

//Done flag
always_ff @(posedge clk or negedge done_rst_n_rst) begin
    if (~done_rst_n_rst) begin
        done <= 1'b0;
    end else begin
        if (assert_done) begin
            done <= 1'b1;
        end
    end
end


endmodule: radix4_booth_fsm
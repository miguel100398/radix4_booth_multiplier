//File:   double_dabble_bin2bcd_fsm.sv
//author: Miguel Bucio miguel_angel_bucio@hotmail.com
//date:   september 4, 2021
//Description:
//          FSM to control the double dabble algorithm
//Dependencies:
//  double_dabble_bin2bcd_pkg.sv



module double_dabble_bin2bcd_fsm
import double_dabble_bin2bcd_pkg::*;
(
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    input  logic start,
    input  logic loops_done,
    input  logic digits_done,
    output logic en_input_reg,
    output logic rst_bcd_reg_n,
    output logic shift_bin,
    output logic shift_bcd,
	output logic loop_count_en,
    output logic loop_count_rst_n,
    output logic bcd_add,
    output logic digit_index_en,
    output logic digit_index_rst_n,
    output logic done
);

//States
double_dabble_bin2bcd_state_e state, next_state;

//Sequential state
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE_S;
    end else if (en) begin
        state <= next_state;
    end
end

//Next state
always_comb begin
    case(state)
        IDLE_S: begin
            next_state = (start) ? SHIFT_S : IDLE_S;
        end
        SHIFT_S: begin
            next_state = CHECK_SHIFT_INDEX_S;
        end
        CHECK_SHIFT_INDEX_S: begin
            next_state = (loops_done) ? BCD_DONE_S : ADD_S;
        end
        ADD_S: begin
            next_state = CHECK_DIGIT_INDEX_S;
        end
        CHECK_DIGIT_INDEX_S: begin
            next_state = (digits_done) ? SHIFT_S : ADD_S;
        end
        BCD_DONE_S: begin
            next_state = IDLE_S;
        end
        default: begin
            next_state = IDLE_S;
        end
    endcase
end

//Outputs
always_comb begin
    case(state)
        IDLE_S: begin
            en_input_reg      = start;
            rst_bcd_reg_n     = ~start;
            loop_count_rst_n  = ~start;
		    digit_index_rst_n = ~start;
			digit_index_en    = 1'b0;
            loop_count_en     = 1'b0;
            shift_bin         = 1'b0;
            shift_bcd         = 1'b0;
            bcd_add           = 1'b0;
            done              = 1'b0;	
        end
        SHIFT_S: begin
            en_input_reg      = 1'b0;
            rst_bcd_reg_n     = 1'b1;
            loop_count_rst_n  = 1'b1;
				digit_index_rst_n = 1'b1;
				digit_index_en    = 1'b0;
            loop_count_en     = 1'b0;
            shift_bin         = 1'b1;
            shift_bcd         = 1'b1;
            bcd_add           = 1'b0;
            done              = 1'b0;
        end
        CHECK_SHIFT_INDEX_S: begin
            en_input_reg      = 1'b0;
            rst_bcd_reg_n     = 1'b1;
            loop_count_rst_n  = 1'b1;
				digit_index_rst_n = 1'b1;
				digit_index_en    = 1'b0;
            loop_count_en     = 1'b1;
            shift_bin         = 1'b0;
            shift_bcd         = 1'b0;
            bcd_add           = 1'b0;
            done              = 1'b0;
        end
        ADD_S: begin
            en_input_reg      = 1'b0;
            rst_bcd_reg_n     = 1'b1;
            loop_count_rst_n  = 1'b1;
				digit_index_rst_n = 1'b1;
				digit_index_en    = 1'b0;
            loop_count_en     = 1'b0;
            shift_bin         = 1'b0;
            shift_bcd         = 1'b0;
            bcd_add           = 1'b1;
            done              = 1'b0;
        end
        CHECK_DIGIT_INDEX_S: begin
            en_input_reg      = 1'b0;
            rst_bcd_reg_n     = 1'b1;
            loop_count_rst_n  = 1'b1;
				digit_index_rst_n = 1'b1;
				digit_index_en    = 1'b1;
            loop_count_en     = 1'b0;
            shift_bin         = 1'b0;
            shift_bcd         = 1'b0;
            bcd_add           = 1'b0;
            done              = 1'b0;
        end
        BCD_DONE_S: begin
            en_input_reg      = 1'b0;
            rst_bcd_reg_n     = 1'b1;
            loop_count_rst_n  = 1'b1;
				digit_index_rst_n = 1'b1;
				digit_index_en    = 1'b0;
            loop_count_en     = 1'b0;
            shift_bin         = 1'b0;
            shift_bcd         = 1'b0;
            bcd_add           = 1'b0;
            done              = 1'b1;
        end
        default: begin
            en_input_reg      = 1'b0;
            rst_bcd_reg_n     = 1'b1;
            loop_count_rst_n  = 1'b1;
				digit_index_rst_n = 1'b1;
				digit_index_en    = 1'b0;
            loop_count_en     = 1'b0;
            shift_bin         = 1'b0;
            shift_bcd         = 1'b0;
            bcd_add           = 1'b0;
            done              = 1'b0;
        end
    endcase
end

endmodule: double_dabble_bin2bcd_fsm
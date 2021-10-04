//File:   double_dabble_bin2bcd_datapath.sv
//author: Miguel Bucio miguel_angel_bucio@hotmail.com
//date:   september 4, 2021
//Description:
//          Datapath to perform the double dabble algorithm
//Dependencies:
//  double_dabble_bin2bcd_pkg.sv


module double_dabble_bin2bcd_datapath
import double_dabble_bin2bcd_pkg::*;
#(
    parameter int unsigned WIDTH          = 4,
    parameter bit          CHECK_PARAM    = 1,
    parameter int unsigned NUM_DIGITS     = get_num_digits(2**WIDTH)
)(
    input  logic             clk,
    input  logic [WIDTH-1:0] bin,
    input  logic             rst_n,
    input  logic             en_input_reg,
    input  logic             rst_bcd_reg_n,
    input  logic             shift_bin,
    input  logic             shift_bcd,
    input  logic             loop_count_rst_n,
    input  logic             loop_count_en,
    input  logic             bcd_add,
    input  logic             digit_index_en,
    input  logic             digit_index_rst_n,
    input  logic             done,
    output logic [3:0]       bcd[NUM_DIGITS],
    output logic             loops_done,
    output logic             digits_done
);


localparam int unsigned LOOP_COUNT_WIDTH = $clog2(WIDTH);
localparam int unsigned DIGIT_INTEX_WIDTH = $clog2(NUM_DIGITS);

logic [WIDTH-1:0] bin_reg;
logic [WIDTH-1:0] bin_shifted;
logic [NUM_DIGITS-1:0][3:0] bcd_reg;
logic [NUM_DIGITS-1:0][3:0] bcd_shifted;
logic [LOOP_COUNT_WIDTH-1:0] loop_count;
logic [DIGIT_INTEX_WIDTH-1:0] digit_index;

//Output
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (int i=0; i<NUM_DIGITS; i++) begin
            bcd[i] <= 4'd0;
        end
    end
    else if (done) begin
        for (int i=0; i<NUM_DIGITS; i++) begin
            bcd[i] <= bcd_reg[i];
        end
    end
end

always_ff @(posedge clk) begin
    if (en_input_reg) begin
        bin_reg <= bin;
    end else if (shift_bin) begin
        bin_reg <= bin_shifted;
    end
end

always_ff @(posedge clk or negedge rst_bcd_reg_n) begin
    if (~rst_bcd_reg_n) begin
        for (int i=0; i<NUM_DIGITS; i++) begin
            bcd_reg[i] <= 4'd0;
        end
    end else if (shift_bcd) begin
        bcd_reg <= bcd_shifted;
    end else if (bcd_add) begin
        if (bcd_reg[digit_index] > 4 ) begin
            bcd_reg[digit_index] <= bcd_reg[digit_index] + 4'd3;
        end
    end
end

//Shifts
always_comb begin
    bcd_shifted       = bcd_reg << 1;
    bcd_shifted[0][0] = bin_reg[WIDTH-1];
    bin_shifted       = bin_reg << 1;
end

//Loop count
assign loops_done = (loop_count == WIDTH-1);

always_ff @(posedge clk or negedge loop_count_rst_n) begin
    if (~loop_count_rst_n) begin
        loop_count <= {LOOP_COUNT_WIDTH{1'b0}};
    end else if (loop_count_en) begin
        loop_count <= loop_count + 1'b1;
    end
end

assign digits_done = (digit_index == NUM_DIGITS-1);

//Digit index
always_ff @(posedge clk or negedge digit_index_rst_n) begin
    if (~digit_index_rst_n) begin
        digit_index <= {DIGIT_INTEX_WIDTH{1'b0}};
    end else if (digit_index_en) begin
        if (digits_done) begin
            digit_index <= {DIGIT_INTEX_WIDTH{1'b0}};    
        end else begin
            digit_index <= digit_index + 1'b1;
        end
    end
end

//Check parameters
`ifndef SYNTHESIS
    generate
        if (CHECK_PARAM) begin : gen_check_param
            if (WIDTH < 1) begin : gen_check_width
                initial begin
                    $fatal("double_dabble_bin2bcd_datapath-check_width(): Error, width can't be less than 1, to disable this check set CHEK_PARAM=0");
                end
            end 
        end // gen_check_param
    endgenerate
`endif //SYNHTESIS

endmodule: double_dabble_bin2bcd_datapath
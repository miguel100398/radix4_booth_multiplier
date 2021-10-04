//File:   double_dabble_bin2bcd.sv
//author: Miguel Bucio miguel_angel_bucio@hotmail.com
//date:   september 4, 2021
//Description:
//          Converts a binary number into a BCD number using the double dabble algorithm
//Parameters:
//  WIDTH      = 4: Width of the binary number to be converted into a BCD number
//Dependencies:
//  double_dabble_bin2bcd_pkg.sv



module double_dabble_bin2bcd
import double_dabble_bin2bcd_pkg::*;
#(
    parameter int unsigned WIDTH          = 4,
    parameter bit          CHECK_PARAM    = 1,
    parameter int unsigned NUM_DIGITS     = get_num_digits(2**WIDTH)
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             start,
    input  logic [WIDTH-1:0] bin,
    output logic [3:0]       bcd[NUM_DIGITS],
    output logic             done
);



logic en_input_reg;
logic rst_bcd_reg_n;
logic shift_bin;
logic shift_bcd;
logic loop_count_rst_n;
logic loop_count_en;
logic loops_done;
logic bcd_add;
logic digit_index_en;
logic digit_index_rst_n;
logic digits_done;
logic bcd_done;

//State machine
double_dabble_bin2bcd_fsm fsm(
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .start(start),
    .loops_done(loops_done),
    .digits_done(digits_done),
    .en_input_reg(en_input_reg),
    .rst_bcd_reg_n(rst_bcd_reg_n),
    .shift_bin(shift_bin),
    .shift_bcd(shift_bcd),
	 .loop_count_en(loop_count_en),
    .loop_count_rst_n(loop_count_rst_n),
    .bcd_add(bcd_add),
    .digit_index_en(digit_index_en),
    .digit_index_rst_n(digit_index_rst_n),
    .done(bcd_done)
);


//Data path
double_dabble_bin2bcd_datapath #(
    .WIDTH(WIDTH),
    .CHECK_PARAM(CHECK_PARAM)
) datapath(
    .clk(clk),
    .bin(bin),
    .rst_n(rst_n),
    .en_input_reg(en_input_reg),
    .rst_bcd_reg_n(rst_bcd_reg_n),
    .shift_bin(shift_bin),
    .shift_bcd(shift_bcd),
    .loop_count_rst_n(loop_count_rst_n),
    .loop_count_en(loop_count_en),
    .bcd_add(bcd_add),
    .digit_index_en(digit_index_en),
    .digit_index_rst_n(digit_index_rst_n),
    .done(bcd_done),
    .bcd(bcd),
    .loops_done(loops_done),
    .digits_done(digits_done)
);

always_ff @(posedge clk) begin
    done <= bcd_done;
end


//Check parameters
`ifndef SYNTHESIS
    generate
        if (CHECK_PARAM) begin : gen_check_param
            if (WIDTH < 1) begin : gen_check_width
                initial begin
                    $fatal("double_dabble_bin2bcd-check_width(): Error, width can't be less than 1, to disable this check set CHEK_PARAM=0");
                end
            end 
        end // gen_check_param
    endgenerate
`endif //SYNHTESIS


endmodule: double_dabble_bin2bcd
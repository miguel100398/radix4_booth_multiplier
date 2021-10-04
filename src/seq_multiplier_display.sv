//Description: Performs sequential multiplication using radix-4 booth multiplier algorithm and displays result in 7 segment display
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 20/09/2021
//Parameters:
//          WIDTH = 8, Length of inputs, the lenght of the output will be 2*WIDTH
//          CHECK_PARAM = 1, If 1 will check that RADIX and WIDTH are valid parameters, if they are not valid the code won´t be compiled
//          NUM_DISPLAYS = 6, Number of seven segment displays

module seq_multiplier_display
import double_dabble_bin2bcd_pkg::*;
#(
    parameter int unsigned WIDTH        = 8,
    parameter bit          CHECK_PARAM  = 1,
    parameter int unsigned NUM_DISPLAYS = 6
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en_n,
    input  logic             start_n,
    input  logic [WIDTH-1:0] multiplier,
    input  logic [WIDTH-1:0] multiplicand,
    output logic             ready,
    output logic [6:0]       displays[6]
);

genvar i;
localparam int unsigned PRODUCT_WIDTH = 2*WIDTH;
localparam int unsigned NUM_DIGITS = get_num_digits(2**PRODUCT_WIDTH);

logic start;
logic en;
logic [PRODUCT_WIDTH-1:0] product;
logic [PRODUCT_WIDTH-1:0] product_abs;
logic start_bin2bcd;
logic [3:0] digits_result [NUM_DIGITS];
logic negative_product;

assign start = ~start_n;
assign en = ~en_n;

radix4_booth_multiplier#(
    .WIDTH(WIDTH),
    .CHECK_PARAM(CHECK_PARAM)
) booth_multiplier (
    .clk(clk),
    .en(en),
    .rst_n(rst_n),
    .start(start),
    .multiplier(multiplier),
    .multiplicand(multiplicand),
    .ready(ready),
    .product(product)
);

pulse_generator pulse_start_bin2bcd(
    .clk(clk),
    .D(ready),
    .Q(start_bin2bcd)
);


double_dabble_bin2bcd#(
    .WIDTH(PRODUCT_WIDTH),
    .CHECK_PARAM(CHECK_PARAM)
) bin2bcd(
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .start(start_bin2bcd),
    .bin(product_abs),
    .bcd(digits_result)
);


abs#(
    .WIDTH(2*WIDTH)
) abs_prod(
    .data_in(product),
    .data_out(product_abs),
    .negative(negative_product)
);

//Seven segment decoders
generate
    //Digits
    for (i=0; i<NUM_DIGITS; i++) begin : gen_seven_segment_decoders
        seven_segment_decoder decoder(
            .decode(digits_result[i]),
            .decoded(displays[i])
        );
    end
    //Sign
    if (NUM_DIGITS < NUM_DISPLAYS) begin : gen_sign
        assign displays[NUM_DIGITS] = {~negative_product, {6{1'b1}}};
    end
    //Turn off extra displays
    for (i=NUM_DIGITS+1; i<NUM_DISPLAYS; i++) begin : gen_extra_displays
        assign displays[i] = 7'b1111111;
    end
endgenerate


generate
    if (CHECK_PARAM) begin : gen_check_param
        if (WIDTH<=0) begin : gen_check_width 
            initial begin 
                $fatal(1, "Error, WIDTH should be greater than 0");
            end
        end
        if (NUM_DISPLAYS < NUM_DIGITS) begin : gen_check_num_displays
            initial begin
                $fatal(1, "Error, NUM_DISPLAYS is less than NUM_DIGITS");
            end
        end
    end
endgenerate

endmodule: seq_multiplier_display
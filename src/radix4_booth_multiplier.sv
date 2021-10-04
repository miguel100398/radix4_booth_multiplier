//Description: Performs sequential multiplication using radix-4 booth multiplier algorithm
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 20/09/2021
//Parameters:
//          WIDTH = 8, Length of inputs, the lenght of the output will be 2*WIDTH
//          CHECK_PARAM = 1, If 1 will check that RADIX and WIDTH are valid parameters, if they are not valid the code won´t be compiled

module radix4_booth_multiplier#(
    parameter int unsigned WIDTH       = 8,
    parameter bit          CHECK_PARAM = 1
)(
    input  logic                clk,
    input  logic                en,
    input  logic                rst_n,
    input  logic                start,
    input  logic[WIDTH-1:0]     multiplier,
    input  logic[WIDTH-1:0]     multiplicand,
    output logic                ready,
    output logic[(2*WIDTH)-1:0] product
);

logic rst_cntr_n;
logic start_booth;
logic en_booth;
logic done_cntr;

//data path
radix4_booth_data_path#(
    .WIDTH(WIDTH),
    .CHECK_PARAM(CHECK_PARAM)
) data_path(
    .clk(clk),
    .rst_n(rst_n),
    .rst_cntr_n(rst_cntr_n),
    .start(start_booth),
    .en(en_booth),
    .multiplier(multiplier),
    .multiplicand(multiplicand),
    .done(done_cntr),
    .result(product)
);

radix4_booth_fsm fsm(
    .clk(clk),
    .en(en),
    .start(start),
    .rst_n(rst_n),
    .done_cntr(done_cntr),
    .start_booth(start_booth),
    .en_booth(en_booth),
    .rst_cntr_n(rst_cntr_n),
    .done(ready)
);

generate
    if (CHECK_PARAM) begin : gen_check_param
        if (WIDTH<=0) begin : gen_check_width 
            initial begin 
                $fatal(1, "Error, WIDTH should be greater than 0");
            end
        end
    end
endgenerate

endmodule: radix4_booth_multiplier
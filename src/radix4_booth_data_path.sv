//Description: radix4_booth_multiplier data path
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 26/09/2021
//Parameters:
//          WIDTH = 8, Multiplier WIDTH
//          CHECK_PARAM = 1, If 1 will check that RADIX and WIDTH are valid parameters, if they are not valid the code won´t be compiled

module radix4_booth_data_path#(
    parameter int unsigned WIDTH       = 8,
    parameter bit          CHECK_PARAM = 1,
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        rst_cntr_n,
    input  logic                        start,
    input  logic                        en,
    input  logic signed [WIDTH-1:0]     multiplier,
    input  logic signed [WIDTH-1:0]     multiplicand,
    output logic                        done,
    output logic [(2*WIDTH)-1:0]        result
);

localparam int unsigned RADIX_WIDTH           = 3;
localparam int unsigned NUM_SHIFTS            = WIDTH/(RADIX_WIDTH-1);
localparam int unsigned MULTIPLIER_WIDTH      = (2*NUM_SHIFTS)+1;
localparam int unsigned EXTRA_MULTIPLER_BITS  = MULTIPLIER_WIDTH-WIDTH;
localparam int unsigned CNTR_WIDTH            = $clog2(NUM_SHIFTS);
localparam int unsigned PARTIAL_PRODUCT_WIDTH = MULTIPLIER_WIDTH+WIDTH+1; 

//Multiplier
logic signed [MULTIPLIER_WIDTH-1:0] multiplier_ext;
logic [2:0] multiplier_bits;
//Multiplicand
logic signed [WIDTH-1:0] multiplicand_reg;
logic signed [WIDTH:0] encoded_multiplicand;
logic signed [PARTIAL_PRODUCT_WIDTH-1:0] encoded_multiplicand_ext;
//Counter
logic [CNTR_WIDTH-1:0] cntr;
logic                  cntr_done;
//Partial product
logic signed [PARTIAL_PRODUCT_WIDTH-1:0] partial_product;
logic signed [PARTIAL_PRODUCT_WIDTH-1:0] partial_product_shift_r;
logic signed [PARTIAL_PRODUCT_WIDTH-1:0] partial_product_add;
logic signed [PARTIAL_PRODUCT_WIDTH-1:0] partial_product_add_shift_r;

//Result 
assign result = partial_product_shift_r[2*WIDTH:1];

//Register multiplicand
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        multiplicand_reg <= {WIDTH{1'b0}};
    end else if (start) begin
        multiplicand_reg <= multiplicand;
    end
end

//Sign extend multiplier
assign multiplier_ext = {{EXTRA_MULTIPLER_BITS{multiplier[WIDTH-1]}}, multiplier};

//Register partial product
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        partial_product <= {PARTIAL_PRODUCT_WIDTH{1'b0}};
    end else if (start) begin
        partial_product <= {{WIDTH{1'b0}}, multiplier_ext, 1'b0};
    end else if (en) begin
        partial_product <= partial_product_add_shift_r;
    end
end

//Multiplier bits
assign multiplier_bits = partial_product[2:0];

radix4_booth_encoder#(
    .WIDTH(WIDTH),
    .CHECK_PARAM(CHECK_PARAM)
) encoder(
    .multiplier_bits(multiplier_bits),
    .multiplicand(multiplicand_reg),
    .encoded_multiplicand(encoded_multiplicand)
);


//Shifters
assign partial_product_shift_r     = partial_product >>> 1;
assign partial_product_add_shift_r = partial_product_add >>> 1;

//Adder
assign encoded_multiplicand_ext = {encoded_multiplicand,{MULTIPLIER_WIDTH{1'b0}}};
assign partial_product_add      = encoded_multiplicand_ext + partial_product_add_shift_r; 

//Counter to finish algorithm
assign cntr_done = (cntr == NUM_SHIFTS-1);

always_ff @(posedge clk or negedge rst_cntr_n) begin
    if (~rst_cntr_n) begin
        cntr <= {CNTR_WIDHT{1'b0}};
    end else if (en) begin
        cntr <= cntr + 1;
    end
end

generate
    if (CHECK_PARAM) begin : gen_check_param
        if (WIDTH<=0) begin : gen_check_width 
            initial begin 
                $fatal(1, "Error, WIDTH should be greater than 0");
            end
        end
    end
endgenerate

endmodule: radix4_booth_data_path
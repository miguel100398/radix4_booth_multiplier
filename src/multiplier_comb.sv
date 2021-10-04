module multiplier_comb#(
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

assign product = multiplier*multiplicand;
assign ready   = 1'b1;

endmodule: multiplier_comb
//File:   abs.sv
//author: Miguel Bucio miguel_angel_bucio@hotmail.com
//date:   september 5, 2021
//Description:
//          Returns the absolute of the number

module abs#(
    parameter WIDTH = 8
)(
    input  logic[WIDTH-1:0] data_in,
    output logic[WIDTH-1:0] data_out,
    output logic negative
);

logic [WIDTH-1:0] data_in_comp;

assign negative = data_in[WIDTH-1];

assign data_in_comp = ~data_in + 1'b1;

assign data_out = (negative) ? data_in_comp : data_in;

endmodule: abs
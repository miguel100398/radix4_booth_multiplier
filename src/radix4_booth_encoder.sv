//Description: Radix4 booth encoding
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 26/09/2021
//Parameters:
//          WIDTH = 8, Multiplicand WIDTH
//          CHECK_PARAM = 1, If 1 will check that WIDTH is a valid parameters, if it is not valid the code won´t be compiled

module radix4_booth_encoder#(
    parameter int unsigned WIDTH       = 8,
    parameter bit          CHECK_PARAM = 1
)(
    input  logic unsigned [2:0]       multiplier_bits,         //Bits to be used to encode multiplicand
    input  logic signed   [WIDTH-1:0] multiplicand,
    output logic signed   [WIDTH:0]   encoded_multiplicand
);

//multiplicand*0
logic [WIDTH:0] multiplicand_x_0;
//Sign extend multiplicand
logic [WIDTH:0] multiplicand_ext;
//multiplicand*2
logic [WIDTH:0] multiplicand_x_2;
//Temporary encoded multiplicand to use only 1 multiplciand*-1
logic [WIDTH:0] tmp_encoded_multiplicand;
//Encoded multiplicand*-1
logic [WIDTH:0] tmp_encoded_multiplicand_neg;

assign multiplicand_x_0 = {(WIDTH+1){1'b0}};
assign multiplicand_ext = {multiplicand[WIDTH-1], multiplicand};
assign multiplicand_x_2 = multiplicand <<< 1;

//Encode multiplicand
always_comb begin 
    case (multiplier_bits)
        3'd0: begin
            tmp_encoded_multiplicand = multiplicand_x_0;  //0
        end
        3'd1: begin
            tmp_encoded_multiplicand = multiplicand_ext; //*1
        end
        3'd2: begin
            tmp_encoded_multiplicand = multiplicand_ext; //*1
        end
        3'd3: begin
            tmp_encoded_multiplicand = multiplicand_x_2; //*2
        end
        3'd4: begin
            tmp_encoded_multiplicand = multiplicand_x_2; //*-2
        end
        3'd5: begin
            tmp_encoded_multiplicand = multiplicand_ext; //*-1
        end
        3'd6: begin
            tmp_encoded_multiplicand = multiplicand_ext; //*-1
        end
        3'd7: begin
            tmp_encoded_multiplicand = multiplicand_x_0; //0
        end
    endcase
end

assign tmp_encoded_multiplicand_neg = ~tmp_encoded_multiplicand + 1'b1;
assign encoded_multiplicand = (multiplier_bits[2]) ? tmp_encoded_multiplicand_neg : tmp_encoded_multiplicand;

generate
    if (CHECK_PARAM) begin : gen_check_param
        if (WIDTH<=0) begin : gen_check_width 
            initial begin 
                $fatal(1, "Error, WIDTH should be greater than 0");
            end
        end
    end
endgenerate

endmodule: radix4_booth_encoder
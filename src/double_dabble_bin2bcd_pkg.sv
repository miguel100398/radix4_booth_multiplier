//File:   double_dabble_bin2bcd_pkg.sv
//author: Miguel Bucio miguel_angel_bucio@hotmail.com
//date:   september 4, 2021
//Description:
//          Defines the parameters and typedefs used by double_dable_bin2bcd

package double_dabble_bin2bcd_pkg;

//Typedefs
typedef enum logic[2:0] {
    IDLE_S              = 3'd0,
    SHIFT_S             = 3'd1,
    CHECK_SHIFT_INDEX_S = 3'd2,
    ADD_S               = 3'd3,
    CHECK_DIGIT_INDEX_S = 3'd4,
    BCD_DONE_S          = 3'd5
} double_dabble_bin2bcd_state_e;


function int get_num_digits(input int max_value);
	get_num_digits = 0;
	
	while ( max_value != 0) begin
		max_value /= 10;
		get_num_digits++;
	end
	
endfunction



endpackage: double_dabble_bin2bcd_pkg
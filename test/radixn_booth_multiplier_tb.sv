module radixn_booth_multiplier_tb;

    parameter int unsigned RADIX       = 4;
    parameter int unsigned WIDTH       = 8;

    logic                clk;
    logic                en;
    logic                rst_n;
    logic                start;
    logic[WIDTH-1:0]     multiplier;
    logic[WIDTH-1:0]     multiplicand;
    logic                ready;
    logic[(2*WIDTH)-1:0] product;

    int exp_result;
    int pass_vectors = 0;
    int fail_vectors = 0;
    int run_vectors = 0;

    radixn_booth_multiplier#(
        .RADIX(RADIX),
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .en(en),
        .rst_n(rst_n),
        .start(start),
        .multiplier(multiplier),
        .multiplicand(multiplicand),
        .ready(ready),
        .product(product)
    );

    //Clock
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    //Clocking block
    
    clocking cb@(posedge clk);
        output en = en;
        output rst_n = rst_n;
        output start = start;
        output multiplier = multiplier;
        output multiplicand = multiplicand;
        input ready = ready;
        input product = product;
    endclocking: cb

    clocking cb_in@(posedge clk);
        input en = en;
        input rst_n = rst_n;
        input start = start;
        input multiplier = multiplier;
        input multiplicand = multiplicand;
    endclocking: cb_in

    //Test
    initial begin
        $display("Starting test");
        calcualte_expected();
        check_expected();
        drive_stimulus();
        $display("finishing test");
        if (fail_vectors != 0) begin
            $fatal($sformatf("Test fail, num_errors: %0d, num_pass: %0d, num_vectos: %0d", fail_vectors, pass_vectors, run_vectors));
        end else begin
            $display($sformatf("Test pass: num_erros: %0d, num_pass: %0d, num_vectors: %0d", fail_vectors, pass_vectors, run_vectors));
        end
        $finish;
    end

    //Drive stimulus
    task drive_stimulus();
        @(cb);
        cb.rst_n <= 0;
        cb.start <= 0;
        cb.en <= 0;
        @(cb);
        cb.rst_n <= 1;
        cb.en <= 1;
        for (int i=0; i<2**WIDTH; i++) begin 
            multiplier = i;
            for (int j=0; j<2**WIDTH; j++) begin
                multiplicand = j;
                @(cb);
                cb.start <= 1;
                @(cb);
                cb.start <= 0;
                @(cb);
                wait(cb.ready);
            end
        end
    endtask: drive_stimulus

    //Caluclate expected
    task calcualte_expected();
        fork
            begin
                forever begin
                    @(cb);
                    if(cb_in.start) begin
                        @(cb);
                        exp_result = signed'(multiplicand) * signed'(multiplier);
                    end
                end              
            end
        join_none
    endtask: calcualte_expected

    task check_expected();
        fork
            begin
                forever begin
                    @(cb);
                    if (cb.ready) begin
                        if (exp_result[(2*WIDTH)-1:0] != cb.product) begin
                            $error($sformatf("Error, expected result: %0d, actual: %0d", exp_result, signed'(cb.product)));
                            fail();
                            $finish;
                        end else begin
                            pass();
                        end
                    end
                end
            end
        join_none
    endtask: check_expected

    function void pass();
        pass_vectors++;
        run_vectors++;
    endfunction: pass

    function void fail();
        fail_vectors++;
        run_vectors++;
    endfunction: fail

endmodule: radixn_booth_multiplier_tb
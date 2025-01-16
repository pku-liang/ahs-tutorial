`timescale 1ns / 1ps

module gemm_kernel_tb;

    // Module Configuration
    parameter int NI = 8;
    parameter int NJ = 8;
    parameter int NK = 8;
    parameter int LOG_NI = $clog2(NI);
    parameter int LOG_NJ = $clog2(NJ);
    parameter int LOG_NK = $clog2(NK);

    // Key Interfaces
    logic clk;
    logic reset;
    logic start;
    logic [31:0] data_out;
    logic valid;
    logic done;

    // Test Storage
    logic [31:0] A [NI][NK];
    logic [31:0] B [NK][NJ];
    logic [31:0] C [NI][NJ];
    logic [31:0] expected_C [NI][NJ];
    logic [31:0] calculated_C [NI][NJ];

    // Variable declaration at the module level
    int result_count;
    int cycle_count;
    int timeout_cycles = 10000; // Set a reasonable timeout value

    // Instantiate the DUT
    gemm_kernel #(
        .NI(NI),
        .NJ(NJ),
        .NK(NK)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_out(data_out),
        .valid(valid),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Testbench process
    initial begin
        // Initialize matrices A and B with specific values
        for (int i = 0; i < NI; i++) begin
            for (int k = 0; k < NK; k++) begin
                A[i][k] = i + k;
            end
        end

        for (int k = 0; k < NK; k++) begin
            for (int j = 0; j < NJ; j++) begin
                B[k][j] = k + j;
            end
        end

        // Write matrix A to "init_a.hex"
        $writememh("init_a.hex", A);

        // Write matrix B to "init_b.hex"
        $writememh("init_b.hex", B);

        // Initialize expected_C matrix
        for (int i = 0; i < NI; i++) begin
            for (int j = 0; j < NJ; j++) begin
                expected_C[i][j] = 0;
                for (int k = 0; k < NK; k++) begin
                    expected_C[i][j] += A[i][k] * B[k][j];
                end
            end
        end

        // Reset the DUT
        reset = 1;
        start = 0;
        #10;
        reset = 0;
        #10;

        // Start the computation
        start = 1;
        #10;
        start = 0;

        // Initialize result_count and cycle_count
        result_count = 0;
        cycle_count = 0;

        // Capture the results and count cycles
        while (!done) begin
            @(posedge clk);
            cycle_count++;
            if (cycle_count > timeout_cycles) begin
                $display("Timeout: Computation did not complete within %0d cycles", timeout_cycles);
                $finish;
            end
            if (valid) begin
                calculated_C[result_count / NJ][result_count % NJ] = data_out;
                result_count++;
            end
        end

        // Verify the results
        for (int i = 0; i < NI; i++) begin
            for (int j = 0; j < NJ; j++) begin
                if (calculated_C[i][j] !== expected_C[i][j]) begin
                    $display("Mismatch at C[%0d][%0d]: Expected %0d, Got %0d", i, j, expected_C[i][j], calculated_C[i][j]);
                end else begin
                    $display("Match at C[%0d][%0d]: %0d", i, j, calculated_C[i][j]);
                end
            end
        end

        // Print the total cycles
        $display("Total cycles taken: %0d", cycle_count);

        // Finish the simulation
        $finish;
    end

endmodule
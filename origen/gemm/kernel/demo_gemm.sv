module gemm_kernel #(
    parameter NI = 4,  // Number of rows in matrix A and C
    parameter NJ = 4,  // Number of columns in matrix B and C
    parameter NK = 4   // Number of columns in A / rows in B
)(
    input logic clk,
    input logic reset,
    input logic start,
    output logic [31:0] data_out,
    output logic valid,
    output logic done
);

// Local parameters, internal signals
localparam IDLE = 3'b000;
localparam READ = 3'b001;
localparam MULTIPLY = 3'b010;
localparam ACCUMULATE = 3'b011;
localparam OUTPUT = 3'b100;

logic [2:0] state, next_state;
logic [31:0] a, b, c;
logic [31:0] sum;
logic [31:0] addr_a, addr_b;
logic [31:0] i, j, k;
logic [31:0] product;

// Instantiate ram_a, ram_b
dual_port_ram #(
    .DATA_WIDTH(32),
    .DATA_DEPTH(NI*NK),
    .ADDR_WIDTH($clog2(NI*NK)),
    .INIT_FILE("init_a.hex")
) ram_a (
    .clk(clk),
    .we(0),
    .start(start),
    .addr_in(addr_a),
    .addr_out(addr_a),
    .di(32'b0),
    .dout(a)
);

dual_port_ram #(
    .DATA_WIDTH(32),
    .DATA_DEPTH(NK*NJ),
    .ADDR_WIDTH($clog2(NK*NJ)),
    .INIT_FILE("init_b.hex")
) ram_b (
    .clk(clk),
    .we(0),
    .start(start),
    .addr_in(addr_b),
    .addr_out(addr_b),
    .di(32'b0),
    .dout(b)
);

// Instantiate multiplier
multiplier #(
    .DATA_WIDTH(32)
) mult (
    .reset(reset),
    .clk(clk),
    .a(a),
    .b(b),
    .p(product)
);

// State machine
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        i <= 0;
        j <= 0;
        k <= 0;
        sum <= 0;
        valid <= 0;
        done <= 0;
    end else begin
        state <= next_state;
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = READ;
                end
            end
            READ: begin
                addr_a <= i * NK + k;
                addr_b <= k * NJ + j;
            end
            MULTIPLY: begin
                // No action needed, product is computed in the multiplier module
            end
            ACCUMULATE: begin
                sum <= sum + product;
                if (k < NK - 1) begin
                    k <= k + 1;
                end else begin
                    k <= 0;
                end
            end
            OUTPUT: begin
                data_out <= sum;
                valid <= 1;
                sum <= 0;
                if (j < NJ - 1) begin
                    j <= j + 1;
                end else begin
                    j <= 0;
                    if (i < NI - 1) begin
                        i <= i + 1;
                    end else begin
                        done <= 1;
                    end
                end
            end
        endcase
    end
end

// Combinational logic
always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (start) begin
                next_state = READ;
            end
        end
        READ: begin
            next_state = MULTIPLY;
        end
        MULTIPLY: begin
            next_state = ACCUMULATE;
        end
        ACCUMULATE: begin
            if (k == NK - 1) begin
                next_state = OUTPUT;
            end else begin
                next_state = READ;
            end
        end
        OUTPUT: begin
            if (i == NI - 1 && j == NJ - 1) begin
                next_state = IDLE;
            end else begin
                next_state = READ;
            end
        end
    endcase
end

// Reset valid signal
always_ff @(posedge clk) begin
    if (valid) begin
        valid <= 0;
    end
end

endmodule
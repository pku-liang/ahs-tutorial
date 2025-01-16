module multiplier #(
    parameter DATA_WIDTH = 32
)(
    input logic reset,
    input logic clk,
    input logic [DATA_WIDTH-1:0] a,
    input logic [DATA_WIDTH-1:0] b,
    output logic [DATA_WIDTH-1:0] p
);
    logic [DATA_WIDTH-1:0] p_reg;
    assign p = p_reg;
    always @(posedge clk) begin
        if (reset) begin
            p_reg <= {DATA_WIDTH{1'b0}};
        end else begin
            p_reg <= a * b;
        end
    end
endmodule

module dual_port_ram #(
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 64,
    parameter ADDR_WIDTH = $clog2(DATA_DEPTH),
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic we,
    input logic start,
    input logic [ADDR_WIDTH-1:0] addr_in, addr_out,
    input logic [DATA_WIDTH-1:0] di,
    output logic [DATA_WIDTH-1:0] dout
);

logic [DATA_WIDTH-1:0] ram [DATA_DEPTH-1:0];

initial begin
    wait (start);
    if (INIT_FILE != "") begin
        $readmemh(INIT_FILE, ram, 0, DATA_DEPTH-1);
    end
end

always @(posedge clk) begin
    if (we)
        ram[addr_in] <= di;
end

//always output the data of the address for simplicity
assign dout = ram[addr_out];

endmodule


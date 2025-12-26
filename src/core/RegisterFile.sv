module RegisterFile(
    input logic clk,
    // operands
    input logic [4:0]   srcA,
    input logic [4:0]   srcB,
    input logic [4:0]   srcC,
    input logic [4:0]   srcD,

    // write enable
    input logic         writeEnable,
    // write data
    input logic [4:0]   dest,
    input logic [31:0]  writeData,

    // Outputs
    output logic [31:0] outputA,
    output logic [31:0] outputB,
    output logic [31:0] outputC,
    output logic [31:0] outputD
);
    logic [31:0] memA [31:0];
    logic [31:0] memB [31:0];
    logic [31:0] memC [31:0];
    logic [31:0] memD [31:0];

    logic [31:0] internalA;
    logic [31:0] internalB;
    logic [31:0] internalC;
    logic [31:0] internalD;

    // Read Logic
    always_ff @( negedge clk ) begin
        internalA <= memA[srcA];
        internalB <= memB[srcB];
        internalC <= memC[srcC];
        internalD <= memD[srcD];
    end

    // Write Logic
    always_ff @( posedge clk ) begin
        if (writeEnable) begin
            memA[dest] <= writeData;
            memB[dest] <= writeData;
            memC[dest] <= writeData;
            memD[dest] <= writeData;
        end
    end

    // Output Logic
    always_comb begin
        outputA = (srcA == 0) ? 32'b0 : internalA;
        outputB = (srcB == 0) ? 32'b0 : internalB;
        outputC = (srcC == 0) ? 32'b0 : internalC;
        outputD = (srcD == 0) ? 32'b0 : internalD;
    end

endmodule
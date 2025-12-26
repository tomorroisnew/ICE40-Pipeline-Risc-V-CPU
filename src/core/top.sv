// Temp Module for checking overall Device Utilisation when synthesizing

module top (
    input  wire clk,
    input  wire reset,
    output wire led
);

    wire [63:0] fetchedInstruction = 64'b0;
    wire [31:0] branchTarget = 32'b0;
    wire        branchTaken = 1'b0;

    InstructionFetcher u_fetch (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .fetchedInstruction(fetchedInstruction),
        .branchTarget(branchTarget),
        .branchTaken(branchTaken),
        .instructionA(),
        .instructionB(),
        .addressA(),
        .addressB(),
        .instructionA_valid(),
        .instructionB_valid()
    );

    assign led = clk; // dummy

endmodule

module InstructionFetcher(
    // Data from I-Cache
    input logic [63:0] fetchedInstruction,

    // Control
    input logic         clk,
    input logic         stall,
    input logic         reset,

    //Data from Branch Unit
    input logic [31:0]  branchTarget,
    input logic         branchTaken,
    
    // Data to I-Cache
    output logic [31:0] instructionAddress,

    // Data to Instruction Buffer
    output logic [31:0] instructionA,
    output logic [31:0] instructionB,
    output logic        instructionA_valid,
    output logic        instructionB_valid
);

    logic [31:0] pc;
    assign instructionAddress = {pc[31:3], 3'b000};

    // Delayed Control signals
    logic delayed_pc2;     // For the memory alignment part, check if the arrived data from last cycle is aligned by 4 or not

    // Slice the instruction bus outside of the always block to please Icarus
    logic [31:0] upper_word, lower_word;
    assign lower_word = fetchedInstruction[31:0];
    assign upper_word = fetchedInstruction[63:32];

    // Update PC logic
    always_ff @( posedge clk ) begin
        if (reset) begin
            pc <= 32'h0;
        end else if (!stall) begin
            if (branchTaken) begin
                pc <= branchTarget;
            end else begin
                pc <= (pc[2]) ? (pc + 32'd4) : (pc + 32'd8);
            end
        end
    end

    // Delay Control Signals Because I-Cache have one cycle latency
    always_ff @( posedge clk ) begin
        if (reset) begin
            delayed_pc2     <= 0;
        end else if (!stall) begin
            if (branchTaken) begin
                delayed_pc2     <= branchTarget[2];
            end else begin
                delayed_pc2     <= pc[2];
            end
        end
    end

    // Memory Alignment logic
    always_comb begin
        // Default values to prevent latches
        instructionA = 32'h0;
        instructionB = 32'h0;
        instructionA_valid = 1'b0;
        instructionB_valid = 1'b0;

        if (!branchTaken && !stall && !reset) begin
            // Check if its aligned by 4
            if (delayed_pc2) begin
                instructionA_valid = 1;
                instructionB_valid = 0;
                instructionA       = upper_word;
                instructionB       = 32'h0;
            end else begin
                instructionA_valid = 1;
                instructionB_valid = 1;
                instructionA       = lower_word;
                instructionB       = upper_word;
            end
        end
    end

endmodule
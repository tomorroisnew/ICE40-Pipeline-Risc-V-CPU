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
    output logic [31:0] addressA,
    output logic [31:0] addressB,
    output logic        instructionA_valid,
    output logic        instructionB_valid
);

    logic [31:0] pc;
    assign instructionAddress = {pc[31:3], 3'b000};

    // Delayed Control signals
    logic delayed_pc2;              // For the memory alignment part, check if the arrived data from last cycle is aligned by 4 or not
    logic delayed_stall;
    logic fetch_buf_valid;          // Handle special case when stall and branch is at the same time.
    logic [31:0] delayed_pc;        // Part of metadata
    logic [63:0] savedInstruction;  // For stalling

    // Branch Predictor fields
    logic [31:0] instruction_low;
    logic [31:0] instruction_high;
    assign instruction_low = delayed_stall ? savedInstruction[31:0]  : fetchedInstruction[31:0];
    assign instruction_high = delayed_stall ? savedInstruction[63:32] : fetchedInstruction[63:32];

    logic take_branch;
    logic instrBSkipped;
    logic [31:0] target;

    BranchPredictor branchPredictor(
        .instruction_low(instruction_low),
        .instruction_high(instruction_high),
        .delayed_pc2(delayed_pc2),
        .delayed_pc(delayed_pc),
        .take_branch(take_branch),
        .target(target),
        .instrBSkipped(instrBSkipped)
    );

    // Update PC logic
    always_ff @( posedge clk ) begin
        if (reset) begin
            pc <= 32'h0;
        end else if (branchTaken) begin
            pc <= branchTarget;
        end else if (!stall) begin
            if (take_branch) begin
                pc <= target;
            end else begin
                pc <= (pc[2]) ? (pc + 32'd4) : (pc + 32'd8);
            end
        end
    end

    // Delay Control Signals Because I-Cache have one cycle latency
    always_ff @( posedge clk ) begin
        if (reset) begin
            delayed_pc2     <= 0;
            fetch_buf_valid <= 0;
            delayed_stall   <= 0;
            delayed_pc      <= 0;
            savedInstruction <= 0;
        end else if (branchTaken) begin
            fetch_buf_valid <= 0;
        end else if (take_branch) begin
            fetch_buf_valid <= 0;
        end else if (!stall) begin
            delayed_pc2     <= branchTaken ? branchTarget[2] : pc[2];
            fetch_buf_valid <= 1;
        end
        delayed_pc       <= pc;
        savedInstruction <= fetchedInstruction;
        delayed_stall    <= stall;
    end

    // Memory Alignment logic
    always_comb begin
        // Default values to prevent latches
        instructionA       = 32'h0;
        instructionB       = 32'h0;
        addressA           = 32'h0;
        addressB           = 32'h0;
        instructionA_valid = 1'b0;
        instructionB_valid = 1'b0;

        if (fetch_buf_valid && !stall && !reset) begin
            // Check if its aligned by 4
            if (delayed_pc2) begin
                instructionA_valid = 1;
                instructionB_valid = 0;
                instructionA       = delayed_stall ? savedInstruction[63:32] : fetchedInstruction[63:32];
                instructionB       = 32'h0;
                addressA           = delayed_pc;
                addressB           = 32'h0;
            end else begin
                instructionA_valid = 1;
                instructionB_valid = 1 & !instrBSkipped;
                instructionA       = delayed_stall ? savedInstruction[31:0]  : fetchedInstruction[31:0];
                instructionB       = delayed_stall ? savedInstruction[63:32] : fetchedInstruction[63:32];
                addressA           = delayed_pc;
                addressB           = delayed_pc + 32'd4;
            end
        end
    end

endmodule
module BranchPredictor(
    // Instructions Inputs
    input logic [31:0] instruction_low,
    input logic [31:0] instruction_high,

    input logic delayed_pc2,
    input logic [31:0] delayed_pc,

    output logic take_branch,
    output logic signed [31:0] target,
    output logic instrBSkipped
);

    logic is_branch_0;
    logic is_back_0;
    logic predict_0;
    logic signed [31:0] imm_0;

    logic is_branch_1;
    logic is_back_1;
    logic predict_1;
    logic signed [31:0] imm_1;

    assign is_branch_0 = instruction_low[6:0] == 7'b1100011;
    assign is_back_0   = instruction_low[31];
    assign predict_0   = is_branch_0 && is_back_0;
    assign imm_0       = {{19{instruction_low[31]}}, instruction_low[31], instruction_low[7], instruction_low[30:25], instruction_low[11:8], 1'b0 };

    assign is_branch_1 = instruction_high[6:0] == 7'b1100011;
    assign is_back_1   = instruction_high[31];
    assign predict_1   = is_branch_1 && is_back_1;
    assign imm_1       = {{19{instruction_high[31]}}, instruction_high[31], instruction_high[7], instruction_high[30:25], instruction_high[11:8], 1'b0 };

    always_comb begin
        // Default output so it dont latch
        take_branch   = 0;
        target        = 32'h0;
        instrBSkipped = 0;


        if (delayed_pc2) begin // Only the second instruction is there
            if (predict_1) begin
                take_branch = 1;
                target      = delayed_pc + 4 + imm_1;
            end
        end else begin
            if (predict_0) begin
                take_branch   = 1;
                target        = delayed_pc + imm_0;
                instrBSkipped = 1;
            end else if (predict_1) begin
                take_branch = 1;
                target      = delayed_pc + 4 + imm_1;
            end 
        end
    end

endmodule
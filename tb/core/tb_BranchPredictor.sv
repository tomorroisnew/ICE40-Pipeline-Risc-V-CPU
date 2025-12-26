module tb_BranchPredictor;

    // --- Inputs/Outputs ---
    logic [31:0] instruction_low;
    logic [31:0] instruction_high;
    logic        delayed_pc2;
    logic [31:0] delayed_pc;

    logic        take_branch;
    logic signed [31:0] target;
    logic        instrBSkipped;
    
    // FIX: Define NOP here (module level), not inside 'initial'
    logic [31:0] NOP = 32'h00000013; 

    // --- DUT Instance ---
    BranchPredictor dut (
        .instruction_low(instruction_low),
        .instruction_high(instruction_high),
        .delayed_pc2(delayed_pc2),
        .delayed_pc(delayed_pc),
        .take_branch(take_branch),
        .target(target),
        .instrBSkipped(instrBSkipped)
    );

    // --- Helper Function: Generate RISC-V Branch Instruction ---
    function logic [31:0] encode_branch(input signed [31:0] offset);
        logic [12:0] imm;
        imm = offset[12:0]; 
        
        return {
            imm[12],         // [31]
            imm[10:5],       // [30:25]
            5'd0,            // [24:20] rs2 (x0)
            5'd0,            // [19:15] rs1 (x0)
            3'b000,          // [14:12] funct3 (BEQ)
            imm[4:1],        // [11:8]
            imm[11],         // [7]
            7'b1100011       // [6:0] Opcode (BRANCH)
        };
    endfunction

    // --- Helper Task: Check Results ---
    task check(
        input string name,
        input logic exp_take,
        input logic signed [31:0] exp_target,
        input logic exp_skip
    );
        begin
            #1; // Wait for logic to settle
            if (take_branch !== exp_take || 
               (exp_take && target !== exp_target) || 
               instrBSkipped !== exp_skip) begin
                
                $display("❌ %s FAILED", name);
                $display("   Inputs: PC=%h, PC2=%b", delayed_pc, delayed_pc2);
                $display("   Output: Take=%b, Tgt=%h, Skip=%b", take_branch, target, instrBSkipped);
                $display("   Expect: Take=%b, Tgt=%h, Skip=%b", exp_take, exp_target, exp_skip);
            end else begin
                $display("✅ %s PASSED", name);
            end
        end
    endtask

    // --- Main Test Sequence ---
    initial begin
        $dumpfile("branch_predictor.vcd");
        $dumpvars(0);
        $display("\n--- Starting Automatic BranchPredictor TB ---");

        delayed_pc = 32'h1000; // Base PC = 4096

        // ==========================================
        // Test Group 1: Slot 0 (instruction_low)
        // ==========================================
        delayed_pc2 = 0;

        // 1.1 Backward Branch (-32)
        instruction_low  = encode_branch(-32); 
        instruction_high = NOP;
        check("Slot0: Backward (-32)", 1, delayed_pc - 32, 1);

        // 1.2 Forward Branch (+16) -> Not Taken
        instruction_low  = encode_branch(16);
        instruction_high = NOP;
        check("Slot0: Forward (+16) -> Not Taken", 0, 0, 0);

        // ==========================================
        // Test Group 2: Slot 1 (instruction_high)
        // ==========================================
        delayed_pc2 = 0; 

        // 2.1 Backward Branch (-8)
        instruction_low  = NOP;
        instruction_high = encode_branch(-8);
        check("Slot1: Backward (-8)", 1, delayed_pc + 4 - 8, 0);

        // 2.2 Forward Branch (+100) -> Not Taken
        instruction_low  = NOP;
        instruction_high = encode_branch(100);
        check("Slot1: Forward (+100) -> Not Taken", 0, 0, 0);

        // ==========================================
        // Test Group 3: Edge Case (delayed_pc2 = 1)
        // ==========================================
        delayed_pc2 = 1;

        instruction_low  = 32'hDEADBEEF; // Garbage
        instruction_high = encode_branch(-20);
        check("Slot1 Only: Backward (-20)", 1, delayed_pc + 4 - 20, 0);

        $display("--- BranchPredictor TB Done ---\n");
        $finish;
    end

endmodule
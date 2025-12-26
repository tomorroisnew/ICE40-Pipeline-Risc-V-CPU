module tb_InstructionFetcher;

    // DUT Inputs
    logic [63:0] fetchedInstruction;
    logic         clk;
    logic         stall;
    logic         reset;
    logic [31:0]  branchTarget;
    logic         branchTaken;

    // DUT Outputs
    wire [31:0] instructionAddress;
    wire [31:0] instructionA;
    wire [31:0] instructionB;
    wire        instructionA_valid;
    wire        instructionB_valid;
    wire [31:0] addressA;
    wire [31:0] addressB;

    // Instantiate the DUT
    InstructionFetcher dut (
        .fetchedInstruction(fetchedInstruction),
        .clk(clk),
        .stall(stall),
        .reset(reset),
        .branchTarget(branchTarget),
        .branchTaken(branchTaken),
        .instructionAddress(instructionAddress),
        .instructionA(instructionA),
        .instructionB(instructionB),
        .instructionA_valid(instructionA_valid),
        .instructionB_valid(instructionB_valid),
        .addressA(addressA),
        .addressB(addressB)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Mock Instruction Memory
    logic [63:0] mem [0:15];

    always_ff @(posedge clk) begin
        // Default value if address is out of bounds
        //fetchedInstruction = 64'hDEADBEEF_DEADBEEF;
        // The instructionAddress is 8-byte aligned
        case (instructionAddress)
            32'h0:    fetchedInstruction <= mem[0];
            32'h8:    fetchedInstruction <= mem[1];
            32'h10:   fetchedInstruction <= mem[2];
            32'h18:   fetchedInstruction <= mem[3];
            32'h20:   fetchedInstruction <= mem[4];
            32'h28:   fetchedInstruction <= mem[5];
            32'h30:   fetchedInstruction <= mem[6];
            32'h38:   fetchedInstruction <= mem[7];
            default:  fetchedInstruction <= 64'hDEADBEEF_DEADBEEF;
        endcase
    end

    // Main test sequence
    initial begin
        $dumpfile("InstructionFetcher.vcd");
        $dumpvars(0);
        // Initialize memory
        mem[0] = 64'h11111111_00000000;
        mem[1] = 64'h33333333_22222222;
        mem[2] = 64'h55555555_44444444;
        mem[3] = 64'h77777777_66666666;
        mem[4] = 64'h99999999_88888888;
        mem[5] = 64'hBBBBBBBB_AAAAAAAA;
        mem[6] = 64'hDDDDDDDD_FE0000E3;
        mem[7] = 64'hFFFFFFFF_EEEEEEEE;

        // Initialize signals
        clk = 0;
        reset = 1;
        stall = 0;
        branchTaken = 0;
        branchTarget = 0;

        $display("Starting Testbench for InstructionFetcher");
        $monitor("Time: %0t, PC_Addr: %h, Instr_Addr: %h, Fetched: %h, Stall: %b, Reset: %b, BrTaken: %b, InstrA: %h (%b), InstrB: %h (%b)",
                 $time, dut.pc, instructionAddress, fetchedInstruction, stall, reset, branchTaken, instructionA, instructionA_valid, instructionB, instructionB_valid);

        // 1. Reset sequence
        #10;
        reset = 1;
        #10;
        reset = 0;
        $display("Reset released");

        // After reset, PC should be 0. instructionAddress should be 0.
        // On next cycle, fetchedInstruction will be mem[0].
        // On the cycle after, instructionA/B will be valid.
        #10; // PC=0, instructionAddress=0, fetchedInstruction=mem[0]
        branchTaken = 1;
        branchTarget = 32'h14;
        #10;
        branchTaken = 0;
        #10
        #10
        #10
        stall = 1;
        #10
        branchTaken = 1;
        branchTarget = 32'h14;
        #10
        branchTaken = 0;
        stall = 0;
        #10
        #10
        #10
        stall = 1;
        #10
        stall = 0;
        #10
        #10
        #10
        #10
        #10
        #10
        
        // if (instructionA === 32'h00000000 && instructionB === 32'h11111111 && instructionA_valid && instructionB_valid)
        //     $display("PASSED: PC=0 fetch");
        // else
        //     $display("FAILED: PC=0 fetch");

        // #10;
        // #10;
        // stall = 1;
        // #10;
        // #10;
        // stall = 0;
        // #10;
        // #10;
        // branchTaken = 1;
        // branchTarget = 32'h8;
        // #10;
        // branchTaken = 0;
        // #10;
        // #10;
        // #10;


        $display("Test Finished");
        $finish;
    end

    // --- Dummy Instruction Buffer ---
    // This simulates the "Consumer" (The next stage of your CPU)
    logic [31:0] consumed_history [0:63];
    integer write_ptr = 0;

    always @(posedge clk) begin
        if (reset) begin
            write_ptr <= 0;
        end else begin
            // Rule: Data is only consumed if Valid is HIGH and Stall is LOW
            if (!stall) begin
                if (instructionA_valid) begin
                    consumed_history[write_ptr] <= instructionA;
                    $display("Time: %0t | [BUFFER] Consumed A: %h PC: %h (Total: %0d)", $time, instructionA, addressA, write_ptr + 1);
                    write_ptr <= write_ptr + 1;
                    
                    // If A and B are both valid, consume B too (Double Push)
                    if (instructionB_valid) begin
                        consumed_history[write_ptr + 1] <= instructionB;
                        $display("Time: %0t | [BUFFER] Consumed B: %h PC: %h (Total: %0d)", $time, instructionB, addressB, write_ptr + 2);
                        write_ptr <= write_ptr + 2;
                    end
                end
            end else begin
                // While stall is high, the buffer is "closed"
                // Even if the wires have data, we don't increment write_ptr
            end
        end
    end

    // Final Report
    final begin
        $display("\n--- Final Buffer History ---");
        for (int i = 0; i < write_ptr; i++) begin
            $display("Slot [%0d]: %h", i, consumed_history[i]);
        end
    end

endmodule
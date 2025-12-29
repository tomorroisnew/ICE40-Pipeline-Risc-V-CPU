module tb_InstructionBuffer();

    logic [31:0] instructionA;
    logic [31:0] instructionB;
    logic [31:0] addressA;
    logic [31:0] addressB;
    logic        instructionA_valid;
    logic        instructionB_valid;

    // Input from dispatcher
    logic pop0;
    logic pop1;


    // Signals
    logic clk;
    logic rst;
    logic flush;

    // 3 Read Ports to Decoder/Dispatcher
    logic [31:0] entry0_instruction;
    logic [31:0] entry0_address;
    logic [31:0] entry1_instruction;
    logic [31:0] entry1_address;
    logic [3:0]  entry_count;

    // Signal to instruction Fetcher
    logic stall;

    // DUT Inputs
    logic [63:0] fetchedInstruction;
    //logic         clk;
    //logic         stall;
    //logic         reset;
    logic [31:0]  branchTarget;
    logic         branchTaken;

    // DUT Outputs
    wire [31:0] instructionAddress;
    //wire [31:0] instructionA;
    //wire [31:0] instructionB;
    //wire        instructionA_valid;
    //wire        instructionB_valid;
    //wire [31:0] addressA;
    //wire [31:0] addressB;

    // Instantiate the DUT
    InstructionFetcher dut (
        .fetchedInstruction(fetchedInstruction),
        .clk(clk),
        .stall(stall),
        .reset(rst),
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

    InstructionBuffer dut2(
        .instructionA(instructionA),
        .instructionB(instructionB),
        .addressA(addressA),
        .addressB(addressB),
        .instructionA_valid(instructionA_valid),
        .instructionB_valid(instructionB_valid),
        .pop0(pop0),
        .pop1(pop1),
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .entry0_instruction(entry0_instruction),
        .entry0_address(entry0_address),
        .entry1_instruction(entry1_instruction),
        .entry1_address(entry1_address),
        .entry_count(entry_count),
        .stall(stall)
    );

    always #5 clk = ~clk;

    logic [31:0] consumedInstruction0;
    logic [31:0] consumedInstruction1;

    always_comb begin
        pop0 = 0;
        pop1 = 0;

        if (entry0_instruction == 32'h11111111 || entry0_instruction == 32'h11111112) begin
            pop0 = 1;
        end
            

        if (entry1_instruction == 32'h11111111 || entry1_instruction == 32'h11111112) begin
            pop1 = 1;
        end
    end

    always_ff @( posedge clk ) begin : blockName
        if (entry0_instruction == 32'h11111111) begin
            consumedInstruction0 <= entry0_instruction;
        end else if (entry0_instruction == 32'h11111112) begin
            consumedInstruction0 <= entry0_instruction;
        end

        if (entry1_instruction == 32'h11111111) begin
            consumedInstruction1 <= entry1_instruction;
        end else if (entry1_instruction == 32'h11111112) begin
            consumedInstruction1 <= entry1_instruction;
        end
    end

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

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
        clk = 0;
        #10;
        clk = 0;
        pop0 = 0;
        pop1 = 0;
        // instructionA_valid = 0;
        // instructionB_valid = 0;
        // addressA = 32'h0;
        // addressB = 32'h0;
        // instructionA = 32'h0;
        // instructionB = 32'h0;

        rst = 1;

        #30;
        rst = 0;
        #10;
        // instructionA_valid = 1;
        // instructionA = 32'h11111112;
        // addressA     = 32'h12345678;
        #10;
        // instructionA_valid = 1;
        // instructionA = 32'h11111111;
        // addressA     = 32'h12345678;
        #10;
        // instructionA_valid = 0;
        #10;
        #10;
        // if (!stall) begin
        //     instructionA_valid = 1;
        //     instructionA = 32'h11111113;
        //     addressA     = 32'h12345678;
        //     instructionB_valid = 1;
        //     instructionB = 32'h11111112;
        //     addressB     = 32'h12345678;
        // end else begin
        //     instructionA_valid = 0;
        //     instructionB_valid = 0;
        // end
        #10;
        // instructionA_valid = 0;
        // instructionB_valid = 0;
        #10;
        // if (!stall) begin
        //     instructionA_valid = 1;
        //     instructionA = 32'h11111113;
        //     addressA     = 32'h12345678;
        //     instructionB_valid = 1;
        //     instructionB = 32'h11111112;
        //     addressB     = 32'h12345678;
        // end else begin
        //     instructionA_valid = 0;
        //     instructionB_valid = 0;
        // end
        #10;
        // if (!stall) begin
        //     instructionA_valid = 1;
        //     instructionA = 32'h11111113;
        //     addressA     = 32'h12345678;
        //     instructionB_valid = 1;
        //     instructionB = 32'h11111112;
        //     addressB     = 32'h12345678;
        // end else begin
        //     instructionA_valid = 0;
        //     instructionB_valid = 0;
        // end
        #10;
        // if (!stall) begin
        //     instructionA_valid = 1;
        //     instructionA = 32'h11111113;
        //     addressA     = 32'h12345678;
        //     instructionB_valid = 1;
        //     instructionB = 32'h11111112;
        //     addressB     = 32'h12345678;
        // end else begin
        //     instructionA_valid = 0;
        //     instructionB_valid = 0;
        // end
        #10;
        #10;
        #10;
        $finish;
    end

endmodule
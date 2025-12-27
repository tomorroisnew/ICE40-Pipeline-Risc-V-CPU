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

    InstructionBuffer dut(
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

    initial begin
        clk = 0;
        #10;
        clk = 0;
        pop0 = 0;
        pop1 = 0;
        instructionA_valid = 0;
        instructionB_valid = 0;
        addressA = 32'h0;
        addressB = 32'h0;
        instructionA = 32'h0;
        instructionB = 32'h0;
        $dumpfile("InstructionBuffer.vcd");
        $dumpvars(0);

        rst = 1;

        #30;
        rst = 0;
        #10;
        instructionA_valid = 1;
        instructionA = 32'h11111111;
        addressA     = 32'h12345678;
        #10;
        instructionA_valid = 0;
        //pop0 = 1;
        #10;
        #10;
        #10;
        #10;
        #10;
        $finish;
    end

endmodule
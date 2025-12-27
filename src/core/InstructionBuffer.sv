module InstructionBuffer(
    // Input from Instruction Fetcher
    input logic [31:0] instructionA,
    input logic [31:0] instructionB,
    input logic [31:0] addressA,
    input logic [31:0] addressB,
    input logic        instructionA_valid,
    input logic        instructionB_valid,

    // Input from dispatcher
    input logic pop0, pop1,


    // Signals
    input logic clk,
    input logic rst,
    input logic flush,

    // 3 Read Ports to Decoder/Dispatcher
    output logic [31:0] entry0_instruction,
    output logic [31:0] entry0_address,
    output logic [31:0] entry1_instruction,
    output logic [31:0] entry1_address,
    output logic [3:0]  entry_count,

    // Signal to instruction Fetcher
    output logic stall
);

    logic [63:0] instructionBuffer [7:0];
    logic [3:0] count;
    logic [3:0] tail;

    // Output bottom 3 to dispatcher
    assign entry0_instruction = instructionBuffer[0][31:0];
    assign entry0_address     = instructionBuffer[0][63:32];
    assign entry1_instruction = instructionBuffer[1][31:0];
    assign entry1_address     = instructionBuffer[1][63:32];
    assign entry_count        = count;

    // Stall logic
    assign stall = (count + instructionA_valid + instructionB_valid - pop0 - pop1) >= 8; 
    assign tail  = count - (pop0 + pop1);

    // Fuck ass shifting logic.
    always_ff @(posedge clk) begin
        if (rst || flush) begin
            count <= 0;
        end else begin 
            if (pop0 && pop1) begin
                instructionBuffer[0] <= instructionBuffer[2];
                instructionBuffer[1] <= instructionBuffer[3];
                instructionBuffer[2] <= instructionBuffer[4];
                instructionBuffer[3] <= instructionBuffer[5];
                instructionBuffer[4] <= instructionBuffer[6];
                instructionBuffer[5] <= instructionBuffer[7];
                instructionBuffer[6] <= 0;
                instructionBuffer[7] <= 0;
            end else if (pop0) begin
                instructionBuffer[0] <= instructionBuffer[1];
                instructionBuffer[1] <= instructionBuffer[2];
                instructionBuffer[2] <= instructionBuffer[3];
                instructionBuffer[3] <= instructionBuffer[4];
                instructionBuffer[4] <= instructionBuffer[5];
                instructionBuffer[5] <= instructionBuffer[6];
                instructionBuffer[6] <= instructionBuffer[7];
                instructionBuffer[7] <= 0;
            end else if (pop1) begin
                instructionBuffer[1] <= instructionBuffer[2];
                instructionBuffer[2] <= instructionBuffer[3];
                instructionBuffer[3] <= instructionBuffer[4];
                instructionBuffer[4] <= instructionBuffer[5];
                instructionBuffer[5] <= instructionBuffer[6];
                instructionBuffer[7] <= 0;
            end 

            // --------------------
            // PUSH LOGIC
            // --------------------
            if(instructionA_valid && instructionB_valid && tail <= 6) begin
                instructionBuffer[tail][31:0] <= instructionA;
                instructionBuffer[tail][63:32] <= addressA;
                instructionBuffer[tail + 1][31:0] <= instructionB;
                instructionBuffer[tail + 1][63:32] <= addressB;
            end else if (instructionA_valid && tail <= 7) begin
                instructionBuffer[tail][31:0] <= instructionA;
                instructionBuffer[tail][63:32] <= addressA;
            end else if (instructionB_valid && tail <= 7) begin
                instructionBuffer[tail][31:0] <= instructionB;
                instructionBuffer[tail][63:32] <= addressB;
            end

            // --------------------
            // COUNT LOGIC
            // --------------------
            count <= count + instructionA_valid + instructionB_valid - pop0 - pop1;
        end
    end

endmodule
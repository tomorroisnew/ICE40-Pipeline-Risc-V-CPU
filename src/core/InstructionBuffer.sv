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
    integer i;

    // Output bottom 3 to dispatcher
    assign entry0_instruction = instructionBuffer[0][31:0];
    assign entry0_address     = instructionBuffer[0][63:32];
    assign entry1_instruction = instructionBuffer[1][31:0];
    assign entry1_address     = instructionBuffer[1][63:32];
    assign entry_count        = count;

    // Stall logic
    assign stall = (count + instructionA_valid + instructionB_valid - pop0 - pop1) >= 8;

    logic [63:0] dbg0, dbg1, dbg2, dbg3, dbg4, dbg5, dbg6, dbg7;
    assign dbg0 = instructionBuffer[0];
    assign dbg1 = instructionBuffer[1];
    assign dbg2 = instructionBuffer[2];
    assign dbg3 = instructionBuffer[3];
    assign dbg4 = instructionBuffer[4];
    assign dbg5 = instructionBuffer[5];
    assign dbg6 = instructionBuffer[6];
    assign dbg7 = instructionBuffer[7];

    always_ff @( posedge clk ) begin
        if (rst || flush) begin
            count <= 0;
            for (i = 0; i < 8; i++) begin
                instructionBuffer[i] <= '0;
            end
        end else begin
            if (pop0 && pop1) begin
                for (i = 0; i < 6; i++) begin
                    instructionBuffer[i] <= instructionBuffer[i+2];
                end
                instructionBuffer[6] <= '0;
                instructionBuffer[7] <= '0;

                if (instructionA_valid && instructionB_valid) begin
                    instructionBuffer[count - 2][31:0]  <= instructionA;
                    instructionBuffer[count - 2][63:32] <= addressA;

                    instructionBuffer[count - 1][31:0]      <= instructionB;
                    instructionBuffer[count - 1][63:32]     <= addressB;

                    count <= count; // What is popped just got refilled
                end else if (instructionA_valid) begin
                    instructionBuffer[count - 2][31:0]  <= instructionA;
                    instructionBuffer[count - 2][63:32] <= addressA;
                    count <= count - 1;
                end else begin
                    count <= count - 2;
                end
            end else if (pop0) begin
                for (i = 0; i < 7; i++) begin
                    instructionBuffer[i] <= instructionBuffer[i+1];
                end
                instructionBuffer[7] <= '0;

                if (instructionA_valid && instructionB_valid) begin
                    instructionBuffer[count - 1][31:0]  <= instructionA;
                    instructionBuffer[count - 1][63:32] <= addressA;

                    // Append the other instruction in the top
                    instructionBuffer[count][31:0]      <= instructionB;
                    instructionBuffer[count][63:32]     <= addressB;

                    count <= count + 1;
                end else if(instructionA_valid) begin
                    instructionBuffer[count - 1][31:0]  <= instructionA;
                    instructionBuffer[count - 1][63:32] <= addressA;
                    count <= count;
                end else begin
                    count <= count - 1;
                end
            end else if (pop1) begin
                for (i = 1; i < 7; i++) begin
                    instructionBuffer[i] <= instructionBuffer[i+1];
                end
                instructionBuffer[7] <= '0;

                if (instructionA_valid && instructionB_valid) begin
                    instructionBuffer[count - 1][31:0]  <= instructionA;
                    instructionBuffer[count - 1][63:32] <= addressA;

                    // Append the other instruction in the top
                    instructionBuffer[count][31:0]      <= instructionB;
                    instructionBuffer[count][63:32]     <= addressB;

                    count <= count + 1;
                end else if(instructionA_valid) begin
                    instructionBuffer[count - 1][31:0]  <= instructionA;
                    instructionBuffer[count - 1][63:32] <= addressA;
                    count <= count;
                end else begin
                    count <= count - 1;
                end
            end else begin
                if (instructionA_valid && instructionB_valid) begin
                    // Append on top
                    instructionBuffer[count][31:0]  <= instructionA;
                    instructionBuffer[count][63:32] <= addressA;

                    instructionBuffer[count + 1][31:0]      <= instructionB;
                    instructionBuffer[count + 1][63:32]     <= addressB;

                    count <= count + 2;
                end else if (instructionA_valid) begin
                    instructionBuffer[count][31:0]  <= instructionA;
                    instructionBuffer[count][63:32] <= addressA;
                    count <= count + 1;
                end else begin
                    count <= count;
                end
            end
        end
    end

endmodule
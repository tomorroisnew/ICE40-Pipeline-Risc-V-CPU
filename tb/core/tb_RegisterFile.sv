module RegisterFile_tb;

    // Inputs
    logic clk;
    logic [4:0] srcA, srcB, srcC, srcD;
    logic writeEnable;
    logic [4:0] dest;
    logic [31:0] writeData;

    // Outputs
    logic [31:0] outputA, outputB, outputC, outputD;

    // Instantiate the Unit Under Test (UUT)
    RegisterFile uut (
        .clk(clk), 
        .srcA(srcA), 
        .srcB(srcB), 
        .srcC(srcC), 
        .srcD(srcD), 
        .writeEnable(writeEnable), 
        .dest(dest), 
        .writeData(writeData), 
        .outputA(outputA), 
        .outputB(outputB), 
        .outputC(outputC), 
        .outputD(outputD)
    );

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        // Dump VCD for waveform analysis
        $dumpfile("dump.vcd");
        $dumpvars(0, RegisterFile_tb);

        // Initialize Inputs
        srcA = 0; srcB = 0; srcC = 0; srcD = 0;
        writeEnable = 0;
        dest = 0;
        writeData = 0;

        // Wait for global reset/startup
        #20;

        // ------------------------------------------------------------
        // Test 1: Basic Write and Read
        // ------------------------------------------------------------
        @(posedge clk);
        $display("Test 1: Write 0xDEADBEEF to x1");
        writeEnable = 1;
        dest = 5'd1;
        writeData = 32'hDEADBEEF;
        
        @(posedge clk);
        writeEnable = 0; // Stop writing

        // Read back on Port A
        $display("Test 1: Read x1 on Port A");
        srcA = 5'd1;
        
        // The design reads on negedge. We set srcA after posedge.
        // Data should be latched at the upcoming negedge.
        @(negedge clk);
        #1; // Small delay to allow for propagation
        
        if (outputA === 32'hDEADBEEF) $display("PASS: x1 read correctly");
        else $error("FAIL: x1 read %h, expected DEADBEEF", outputA);

        // ------------------------------------------------------------
        // Test 2: Register Zero Behavior
        // ------------------------------------------------------------
        @(posedge clk);
        $display("Test 2: Attempt to write to x0");
        writeEnable = 1;
        dest = 5'd0;
        writeData = 32'hFFFFFFFF;

        @(posedge clk);
        writeEnable = 0;

        // Read back on Port B
        srcB = 5'd0;
        @(negedge clk);
        #1;

        if (outputB === 32'b0) $display("PASS: x0 is 0 (Hardwired)");
        else $error("FAIL: x0 read %h, expected 0", outputB);

        // ------------------------------------------------------------
        // Test 3: Timing Check
        // ------------------------------------------------------------
        // Verify data is ready before the next cycle (next posedge)
        // Since we read on negedge, data is valid 1/2 cycle before next posedge.
        if (outputA === 32'hDEADBEEF) 
            $display("PASS: Data valid immediately before next cycle (at negedge)");
        
        #20;
        $finish;
    end
endmodule

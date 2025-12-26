// simple_alu.sv
module simple_alu (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       op, // 0 for add, 1 for sub
    output logic [4:0] result
);

    // always_comb ensures there are no accidental latches
    always_comb begin
        if (op == 1'b0) begin
            result = a + b;
        end else begin
            result = a - b;
        end
    end

endmodule


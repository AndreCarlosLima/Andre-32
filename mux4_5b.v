module mux4_5b (
    input  wire [4:0] in0,
    input  wire [4:0] in1,
    input  wire [4:0] in2,
    input  wire [4:0] in3,
    input  wire [1:0] sel,
    output reg  [4:0] out
);
    always @(*) begin
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = 5'b0;
        endcase
    end
endmodule
module ULA (
    input  [31:0] A,          // Operando 1 
    input  [31:0] B,          // Operando 2 
    input  [3:0]  Ctrl,       // Controle 
    output reg [31:0] Result, // Resultado da operação
    output        Zero        // Flag zero
);

    // A flag Zero é fundamental para saltos condicionais.
    // Se Result for 0, Zero será 1.
    assign Zero = (Result == 32'b0);

    always @(*) begin
        case (Ctrl)
            4'b0000: Result = A + B;          // ADD, ADDI, LW, SW, PUSH, POP
            4'b0001: Result = A - B;          // SUB, BEQ, BNE
            4'b0010: Result = A * B;          // MUL
            4'b0011: Result = (B != 0) ? (A / B) : 32'b0; // DIV
            4'b0100: Result = A & B;          // AND
            4'b0101: Result = A | B;          // OR
            4'b0110: Result = A ^ B;          // XOR
            4'b0111: Result = ~(A | B);       // NOR
            4'b1000: Result = B << A[4:0];    // SLL
            4'b1001: Result = B >> A[4:0];    // SRL
            4'b1010: Result = (A < B) ? 32'b1 : 32'b0; // SLT
            4'b1011: Result = B;              // PASS_B (Passa o valor de B direto)
            4'b1100: Result = (B != 0) ? (A % B) : 32'b0; // REM
            4'b1101: Result = ( {32'b0, A} * {32'b0, B} ) >> 32;   // MULH
				4'b1110: Result = (A == B) ? 32'b1 : 32'b0; //BNE
				4'b1111: Result = B << 16; //LUI	
            
            default: Result = 32'h0;
        endcase
    end
endmodule
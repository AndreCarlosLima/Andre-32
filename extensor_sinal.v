module extensor_sinal (
    input  wire [25:0] imm_in,   // Aumentado para pegar até 26 bits da memória de instrução
    input  wire [1:0]  SngExt,   // Controle agora tem 2 bits (00 = 16b | 01 = 21b | 10 = 26b)
    output reg  [31:0] imm_out
);

    always @(*) begin
        case (SngExt)
            2'b00: begin
                // Extensão de sinal de 16 bits (Instruções tipo I: ADDI, BEQ, etc)
                imm_out = { {16{imm_in[15]}}, imm_in[15:0] };
            end
            2'b01: begin
                // Extensão de sinal de 21 bits (Instruções tipo E: LI, LW_ABS, etc)
                imm_out = { {11{imm_in[20]}}, imm_in[20:0] };
            end
            2'b10: begin
                // Ajuste de 26 bits (Instruções tipo J: JUMP, JAL)
                // Preenchemos com 6 zeros à esquerda para formar 32 bits
                imm_out = { 6'b000000, imm_in[25:0] };
            end
            default: begin
                imm_out = 32'b0;
            end
        endcase
    end

endmodule
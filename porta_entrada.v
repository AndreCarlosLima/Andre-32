module porta_entrada (
    input  wire [9:0]  chaves_in, // SW[9] (MSB) até SW[0] (LSB)
    output wire [31:0] in_port    // Fio de 32 bits que vai para o processador
);

    // O barramento de 32 bits é formado por:
    // 22 bits de zeros (para preencher o espaço vazio) seguidos pelos 10 bits das chaves.
    assign in_port = { 22'b0, chaves_in };

endmodule
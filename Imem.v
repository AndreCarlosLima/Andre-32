module Imem #(
    parameter DATA_WIDTH = 32, 
    parameter ADDR_WIDTH = 6
)(
    input  wire [(ADDR_WIDTH-1):0] addr, // Conectado direto na saída do registrador PC
    output wire [(DATA_WIDTH-1):0] q     // Vai direto para o bloco de Controle e registradores
);

    // Declaração da matriz da memória ROM
    reg [DATA_WIDTH-1:0] rom [2**ADDR_WIDTH-1:0];

    // Inicialização da ROM carregando o arquivo de texto com o programa em binário
    initial begin
        $readmemb("programa.txt", rom);
    end

    // ========================================================
    // LEITURA ASSÍNCRONA (COMBINACIONAL)
    // O clock foi removido. A leitura responde instantaneamente ao PC.
    // ========================================================
    assign q = rom[addr];

endmodule
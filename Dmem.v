module Dmem 
#(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 6  )
(
    input  wire                    clk,  
    input  wire [(DATA_WIDTH-1):0] write_data,
    input  wire [(DATA_WIDTH-1):0] addr_ula,     // Endereço calculado pela ULA 
    input  wire [(DATA_WIDTH-1):0] addr_sp,      // Endereço vindo do registrador SP
    
    // Sinais de Controle
    input  wire                    memtowrite,
    input  wire                    memtoread,
    input  wire                    isstack,
    
    // Saída
    output wire [(DATA_WIDTH-1):0] read_data  
);

    
    reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];
    
    
    wire [ADDR_WIDTH-1:0] endereco_final;
    wire [31:0]           endereco_32;

    // 1. MUX de Endereço: Escolhe entre o endereço da ULA ou o ponteiro da Pilha (SP)
    assign endereco_32 = (isstack == 1'b1) ? addr_sp : addr_ula;
    
    // Trunca o endereço de 32 bits para o tamanho real da sua RAM (6 bits)
    assign endereco_final = endereco_32[ADDR_WIDTH-1:0];

    // 2. ESCRITA SÍNCRONA: Ocorre estritamente na borda de subida do clock geral
    always @(posedge clk) begin
        if (memtowrite) begin
            ram[endereco_final] <= write_data;
        end
    end

    // 3. LEITURA ASSÍNCRONA (COMBINACIONAL): Não depende de clock!
    assign read_data = (memtoread) ? ram[endereco_final] : 32'b0;

    // Inicialização da RAM com zeros (para evitar erros de 'X' no ModelSim)
    integer i;
    initial begin
        for (i = 0; i < (2**ADDR_WIDTH); i = i + 1) begin
            ram[i] = 32'b0;
        end
    end

endmodule
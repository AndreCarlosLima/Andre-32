module processador (
    input clk,
    
    // Entradas de teste (simulando os campos de uma instrução)
    input [4:0] rs,       // Source 1
    input [4:0] rt,       // Source 2
    input [4:0] rd,       // Destination
    
    // Sinais de controle (virão da Unidade de Controle no futuro)
    input regWrite,       // Habilita escrita no banco
    input [3:0] ula_ctrl, // Define a operação da ULA
    
    // Saídas para monitorar na simulação
    output [31:0] saida_resultado,
    output flag_zero
);

    // ==========================================
    // FIOS DE CONEXÃO (DATAPATH)
    // ==========================================
    wire [31:0] w_dado_rs;       // Sai do banco e vai para a ULA (A)
    wire [31:0] w_dado_rt;       // Sai do banco e vai para a ULA (B)
    wire [31:0] w_resultado_ula; // Sai da ULA e volta para o banco (writeData)

    // ==========================================
    // INSTANCIAÇÃO DO SEU BANCO DE REGISTRADORES
    // ==========================================
    banco meu_banco (
        .clk(clk),
        .regWrite(regWrite),
        .readReg1(rs),
        .readReg2(rt),
        .writeReg(rd),
        .writeData(w_resultado_ula), // O resultado da ULA é gravado de volta
        .readData1(w_dado_rs),       // Dado do registrador RS
        .readData2(w_dado_rt)        // Dado do registrador RT
    );

    // ==========================================
    // INSTANCIAÇÃO DA SUA ULA
    // ==========================================
    ULA minha_ula (
        .A(w_dado_rs),            // Recebe o dado de RS
        .B(w_dado_rt),            // Recebe o dado de RT
        .Ctrl(ula_ctrl),          // Sinal que escolhe a operação
        .Result(w_resultado_ula), // Resultado matemático/lógico
        .Zero(flag_zero)          // Flag de zero (útil para saltos)
    );

    // ==========================================
    // SAÍDAS
    // ==========================================
    assign saida_resultado = w_resultado_ula;

endmodule
module proxima_instrucao (
    input  wire [31:0] pc_atual,       
    input  wire [31:0] imediato,       // serve tanto para o Branch quanto para o Jump
    input  wire [31:0] reg_rs_dado,    // Dado lido do Banco de Registradores (para o JR)
    
    // Sinais de Controle e Status
    input  wire        branch,         
    input  wire        zero,           
    input  wire        jump,           
    input  wire        jr_taken,       
    
    // Saídas
    output reg  [31:0] pc_novo,        
    output wire [31:0] pc_mais_1       
);

    // Fios internos
    wire [31:0] fio_branch_target;
    wire        branch_taken;

    // 1. Caminho Padrão: PC + 1
    assign pc_mais_1 = pc_atual + 32'd1;

    // 2. Caminho de Salto Condicional: PC + 1 + imediato
    assign fio_branch_target = pc_mais_1 + imediato; 

    // 3. Porta AND: Condição para o Branch
    assign branch_taken = branch & zero;

    always @(*) begin
        if (jr_taken == 1'b1) begin
            // Prioridade máxima: Retorno de função (JR) pega o valor do registrador
            pc_novo = reg_rs_dado;
        end
        else if (jump == 1'b1) begin
            // Prioridade alta: J ou JAL pegam o valor DIRETO do extensor de sinal
            pc_novo = imediato;
        end 
        else if (branch_taken == 1'b1) begin
            // Prioridade média: Salto condicional
            pc_novo = fio_branch_target;
        end 
        else begin
            // Caminho padrão
            pc_novo = pc_mais_1;
        end
    end

endmodule
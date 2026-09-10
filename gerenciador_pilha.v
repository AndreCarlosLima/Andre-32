module gerenciador_pilha #(
    parameter SP_START = 32'd63 // Ajuste para o endereço final da sua memória RAM
)(
    input  wire        clk,
    input  wire        reset,   // NOVO: Reset físico
    input  wire        push,    
    input  wire        pop,     
    output reg  [31:0] sp_out   
);

    initial begin
        sp_out = SP_START;
    end

    // Atualizado para responder ao reset assíncrono
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sp_out <= SP_START;
        end
        else if (push) begin
            sp_out <= sp_out - 32'd1;
        end
        else if (pop) begin
            sp_out <= sp_out + 32'd1;
        end
    end

endmodule
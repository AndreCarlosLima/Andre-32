module debouncer (
    input  wire clk,      // Clock de 1 MHz
    input  wire rst,      // Reset do sistema
    input  wire btn_in,   // Sinal ruidoso do botão
    output reg  btn_out   // Sinal limpo
);
    reg [14:0] contador;  // 15 bits cobrem até 32.767
    reg estado_atual;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            contador <= 15'd0;
            estado_atual <= 1'b0;
            btn_out <= 1'b0;
        end else begin
            // Se o botão mudou de estado, começa a contar
            if (btn_in != estado_atual) begin
                contador <= contador + 15'd1;
                // Se o sinal ficou estável por 20.000 ciclos (20ms)
                if (contador == 15'd20000) begin
                    estado_atual <= btn_in;
                    btn_out <= btn_in;
                    contador <= 15'd0; // Zera para a próxima transição
                end
            end else begin
                contador <= 15'd0; // Zera o contador se for ruído rápido
            end
        end
    end
endmodule
module divisor_clock (
    input  wire clk_in,   // Clock original da placa (ex: 50 MHz)
    input  wire reset,    // Botão de reset
    output reg  clk_out   // Novo clock reduzido (ex: 1 MHz)
);

    // Como precisamos contar de 0 a 24, precisamos de um registrador de 5 bits (0 a 31)
    reg [4:0] contador;

    always @(posedge clk_in) begin
        if (reset) begin
            contador <= 5'd0;
            clk_out  <= 1'b0;
        end 
        else if (contador == 5'd24) begin
            contador <= 5'd0;       // Zera o contador quando chega no limite
            clk_out  <= ~clk_out;   // Inverte o sinal do clock (0 vira 1, 1 vira 0)
        end 
        else begin
            contador <= contador + 5'd1; // Apenas soma +1 enquanto não chega no 24
        end
    end

endmodule
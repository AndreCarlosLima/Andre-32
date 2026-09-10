module bin_to_bcd (
    input  wire [13:0] bin,       // 14 bits cobrem números de 0 até 16.383
    output reg  [3:0]  milhares,
    output reg  [3:0]  centenas,
    output reg  [3:0]  dezenas,
    output reg  [3:0]  unidades
);
    integer i;
    
    always @(*) begin
        // Zera tudo no início do cálculo
        milhares = 4'd0;
        centenas = 4'd0;
        dezenas  = 4'd0;
        unidades = 4'd0;

        for (i = 13; i >= 0; i = i - 1) begin
            // Se a coluna for maior ou igual a 5, soma 3 (Regra do BCD)
            if (milhares >= 5) milhares = milhares + 3;
            if (centenas >= 5) centenas = centenas + 3;
            if (dezenas >= 5)  dezenas  = dezenas  + 3;
            if (unidades >= 5) unidades = unidades + 3;

            // Desloca tudo 1 bit para a esquerda
            milhares = milhares << 1;
            milhares[0] = centenas[3];
            
            centenas = centenas << 1;
            centenas[0] = dezenas[3];
            
            dezenas = dezenas << 1;
            dezenas[0] = unidades[3];
            
            unidades = unidades << 1;
            unidades[0] = bin[i];
        end
    end
endmodule
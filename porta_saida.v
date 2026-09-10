module porta_saida (
    input  wire        clk,
    input  wire        reset,
    input  wire        out_en,
    input  wire [31:0] dado_in,   
    
    // As saídas para os 4 displays
    output wire [6:0]  hex0_out,  
    output wire [6:0]  hex1_out,
    output wire [6:0]  hex2_out,
    output wire [6:0]  hex3_out
);

    reg [31:0] dado_congelado;

    // Registrador para congelar o valor da ULA
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            dado_congelado <= 32'b0;
        end
        else if (out_en) begin
            dado_congelado <= dado_in;
        end
    end

    // Fios internos para carregar os valores DECIMAIS separados
    wire [3:0] w_milhar;
    wire [3:0] w_centena;
    wire [3:0] w_dezena;
    wire [3:0] w_unidade;

    // Instancia o conversor (pegamos os 14 bits mais baixos, máx 16.383)
    bin_to_bcd conversor_decimal (
        .bin(dado_congelado[13:0]),
        .milhares(w_milhar),
        .centenas(w_centena),
        .dezenas(w_dezena),
        .unidades(w_unidade)
    );

    // Manda os digitos em decimal para os decodificadores
    hex_to_7seg disp0 ( .hex_in(w_unidade), .seg_out(hex0_out) );
    hex_to_7seg disp1 ( .hex_in(w_dezena),  .seg_out(hex1_out) );
    hex_to_7seg disp2 ( .hex_in(w_centena), .seg_out(hex2_out) );
    hex_to_7seg disp3 ( .hex_in(w_milhar),  .seg_out(hex3_out) );

endmodule
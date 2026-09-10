module unidade_de_controle (
    input      [5:0] opcode,
    
    output reg       regWrite,
    output reg       memtoread,
    output reg       memtowrite,
    output reg       isstack,
    output reg       push_en,
    output reg       pop_en,
    output reg       branch,
    output reg       jump,
    output reg       jr_taken,
    output reg       in_en,
    output reg       out_en,
    output reg       hlt,
    output reg [3:0] ULA_Ctrl,
    output reg [1:0] SngExt,
    output reg       ALUSrc,
    output reg [1:0] RegDst,
    output reg [1:0] MemToReg
);

    always @(*) begin
        // Valores padrão para evitar latches inferidos
        regWrite   = 1'b0; memtoread  = 1'b0; memtowrite = 1'b0;
        isstack    = 1'b0; push_en    = 1'b0; pop_en     = 1'b0;
        branch     = 1'b0; jump       = 1'b0; jr_taken   = 1'b0;
        in_en      = 1'b0; out_en     = 1'b0; hlt        = 1'b0;
        ULA_Ctrl   = 4'b0000; SngExt  = 2'b00; ALUSrc    = 1'b0;
        RegDst     = 2'b00; MemToReg  = 2'b00;

        case (opcode)
            // --- Tipo R (Aritméticas e Lógicas) ---
				6'b000001: begin regWrite = 1; ULA_Ctrl = 4'b0000; RegDst = 2'b01; end // ADD
            6'b000010: begin regWrite = 1; ULA_Ctrl = 4'b0001; RegDst = 2'b01; end // SUB
            6'b000011: begin regWrite = 1; ULA_Ctrl = 4'b0010; RegDst = 2'b01; end // MUL
            6'b000100: begin regWrite = 1; ULA_Ctrl = 4'b1101; RegDst = 2'b01; end // MULH
            //6'b000101: begin regWrite = 1; ULA_Ctrl = 4'b0011; RegDst = 2'b01; end // DIV
            //6'b000110: begin regWrite = 1; ULA_Ctrl = 4'b1100; RegDst = 2'b01; end // REM
            6'b000111: begin regWrite = 1; ULA_Ctrl = 4'b0100; RegDst = 2'b01; end // AND
            6'b001000: begin regWrite = 1; ULA_Ctrl = 4'b0101; RegDst = 2'b01; end // OR
            6'b001001: begin regWrite = 1; ULA_Ctrl = 4'b0110; RegDst = 2'b01; end // XOR
            6'b001010: begin regWrite = 1; ULA_Ctrl = 4'b0111; RegDst = 2'b01; end // NOR
            6'b001011: begin regWrite = 1; ULA_Ctrl = 4'b1010; RegDst = 2'b01; end // SLT
            6'b001100: begin regWrite = 1; ULA_Ctrl = 4'b1001; RegDst = 2'b01; end // SRL
            6'b001101: begin regWrite = 1; ULA_Ctrl = 4'b1000; RegDst = 2'b01; end // SLL

            // --- Saltos ---
            6'b001110: begin jr_taken = 1; end
            6'b011101: begin jump = 1; end
            // JAL: Salva PC+1 no R31
            6'b011110: begin jump = 1; regWrite = 1; RegDst = 2'b10; MemToReg = 2'b10; end
            // BEQ e BNE: Usam a ULA para gerar a flag Zero
            6'b010001: begin branch = 1; ULA_Ctrl = 4'b0001; end
            6'b010010: begin branch = 1; ULA_Ctrl = 4'b1110; end

            // --- Memória ---
            6'b010101: begin regWrite = 1; memtoread = 1; ALUSrc = 1; SngExt = 2'b00; ULA_Ctrl = 4'b0000; RegDst = 2'b01; MemToReg = 2'b01; end
            6'b010110: begin memtowrite = 1; ALUSrc = 1; SngExt = 2'b00; ULA_Ctrl = 4'b0000; end
            // LW_IND e SW_IND: SngExt em 2'b11 emite 0 para a ULA somar (RS + 0)
            6'b010111: begin regWrite = 1; memtoread = 1; ALUSrc = 1; SngExt = 2'b11; ULA_Ctrl = 4'b0000; RegDst = 2'b00; MemToReg = 2'b01; end
            6'b011000: begin memtowrite = 1; ALUSrc = 1; SngExt = 2'b11; ULA_Ctrl = 4'b0000; end
            6'b011011: begin regWrite = 1; memtoread = 1; ALUSrc = 1; SngExt = 2'b01; ULA_Ctrl = 4'b1011; RegDst = 2'b00; MemToReg = 2'b01; end
            6'b011100: begin memtowrite = 1; ALUSrc = 1; SngExt = 2'b01; ULA_Ctrl = 4'b1011; end

            // --- Imediatos e Pilha ---
            6'b010011: begin regWrite = 1; ALUSrc = 1; SngExt = 2'b01; ULA_Ctrl = 4'b1011; RegDst = 2'b00; end
            6'b010100: begin regWrite = 1; ALUSrc = 1; SngExt = 2'b00; ULA_Ctrl = 4'b1111; RegDst = 2'b00; end
            6'b010000: begin regWrite = 1; ALUSrc = 1; SngExt = 2'b00; ULA_Ctrl = 4'b0000; RegDst = 2'b00; end
            6'b011111: begin memtowrite = 1; isstack = 1; push_en = 1; end
            6'b100000: begin regWrite = 1; memtoread = 1; isstack = 1; pop_en = 1; RegDst = 2'b00; MemToReg = 2'b01; end
				
            // --- Sistema e I/O ---
            6'b100001: begin regWrite = 1; in_en = 1; RegDst = 2'b00; MemToReg = 2'b11; end
            6'b100010: begin out_en = 1; end
            6'b111111: begin hlt = 1; end

            default: begin end
        endcase
    end

endmodule
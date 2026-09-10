module processador_final (
    input  wire        clk,             
    input  wire        reset,           // SW17
    input  wire        enter_fisico,    // Botão de Enter (KEY0)
    input  wire [9:0]  chaves,          // SW0 a SW9
    output wire [6:0]  HEX0,            
    output wire [6:0]  HEX1,            
    output wire [6:0]  HEX2,            
    output wire [6:0]  HEX3             
);

    wire clk_1mhz; 
    wire [31:0] in_port; 
    wire [31:0] instrucao, pc_atual, pc_novo, pc_mais_1;
    wire [31:0] w_dado_rs, w_dado_rt, w_ula_b, w_resultado_ula, w_dado_memoria, w_writeData_banco;
    wire [31:0] imm_ext, sp_atual;
    wire [4:0]  w_writeReg;
    wire        flag_zero;
    
    wire c_regWrite, c_memtoread, c_memtowrite, c_isstack, c_push_en, c_pop_en;
    wire c_branch, c_jump, c_jr_taken, c_ALUSrc, c_in_en, c_out_en, c_hlt;
    wire [1:0] c_RegDst, c_MemToReg, c_SngExt;
    wire [3:0] c_ULA_Ctrl;

    divisor_clock meu_divisor ( .clk_in(clk), .reset(reset), .clk_out(clk_1mhz) );

    porta_entrada p_in ( .chaves_in(chaves), .in_port(in_port) );

    porta_saida p_out (
        .clk(clk_1mhz), 
        .reset(reset),
        .out_en(c_out_en),
        .dado_in(w_dado_rs), 
        .hex0_out(HEX0), .hex1_out(HEX1), .hex2_out(HEX2), .hex3_out(HEX3)
    );

    // ==========================================
    // DETECTOR DE BORDA DO BOTÃO ENTER + DEBOUNCER
    // ==========================================
    wire enter_limpo;
    
    debouncer btn_enter_debouncer (
        .clk(clk_1mhz),
        .rst(reset),
        .btn_in(~enter_fisico), 
        .btn_out(enter_limpo)
    );

    reg [2:0] enter_reg = 3'b000;
    
    always @(posedge clk_1mhz or posedge reset) begin
        if (reset) 
            enter_reg <= 3'b000;
        else 
            enter_reg <= {enter_reg[1:0], enter_limpo}; 
    end
    
    wire enter_pulso = enter_reg[1] & ~enter_reg[2]; 
    wire stall = c_in_en & ~enter_pulso;

    // ==========================================
    // REGISTRADOR PC
    // ==========================================
    reg [31:0] pc_reg = 32'b0; 
    assign pc_atual = pc_reg;

    always @(posedge clk_1mhz or posedge reset) begin
        if (reset) 
            pc_reg <= 32'b0;
        else if (!c_hlt && !stall) 
            pc_reg <= pc_novo; 
    end

    // ==========================================
    // DATAPATH 
    // ==========================================
    Imem #(32, 5) imem ( .addr(pc_atual[7:0]), .q(instrucao) );
    wire [5:0] opcode = instrucao[31:26];
    wire [4:0] rs = instrucao[25:21], rt = instrucao[20:16], rd = instrucao[15:11];
    
    unidade_de_controle uc (
        .opcode(opcode), .regWrite(c_regWrite), .memtoread(c_memtoread), .memtowrite(c_memtowrite),
        .isstack(c_isstack), .push_en(c_push_en), .pop_en(c_pop_en),
        .branch(c_branch), .jump(c_jump), .jr_taken(c_jr_taken),
        .in_en(c_in_en), .out_en(c_out_en), .hlt(c_hlt),
        .ULA_Ctrl(c_ULA_Ctrl), .SngExt(c_SngExt), .ALUSrc(c_ALUSrc),
        .RegDst(c_RegDst), .MemToReg(c_MemToReg)
    );

    mux4_5b mux_regdst ( .in0(rt), .in1(rd), .in2(5'd31), .in3(5'd0), .sel(c_RegDst), .out(w_writeReg) );

    banco reg_file (
        .clk(clk_1mhz), .reset(reset), .regWrite(c_regWrite), 
        .readReg1(rs), .readReg2(rt), .writeReg(w_writeReg), .writeData(w_writeData_banco),
        .readData1(w_dado_rs), .readData2(w_dado_rt)
    );

    extensor_sinal ext ( .imm_in(instrucao[25:0]), .SngExt(c_SngExt), .imm_out(imm_ext) );
    
    mux2_32b mux_alusrc ( .in0(w_dado_rt), .in1(imm_ext), .sel(c_ALUSrc), .out(w_ula_b) );
    
    ULA ula ( .A(w_dado_rs), .B(w_ula_b), .Ctrl(c_ULA_Ctrl), .Result(w_resultado_ula), .Zero(flag_zero) );

    gerenciador_pilha pilha ( .clk(clk_1mhz), .reset(reset), .push(c_push_en), .pop(c_pop_en), .sp_out(sp_atual) );
    
	 
	 wire [31:0] sp_corrigido = (c_pop_en) ? (sp_atual + 32'd1) : sp_atual;
    Dmem #(32, 5) dmem (
        .clk(clk_1mhz), .write_data(w_dado_rt), .addr_ula(w_resultado_ula), .addr_sp(sp_corrigido),
        .memtowrite(c_memtowrite), .memtoread(c_memtoread), .isstack(c_isstack), .read_data(w_dado_memoria)
    );

    mux4_32b mux_memtoreg (
        .in0(w_resultado_ula), .in1(w_dado_memoria), .in2(pc_mais_1), .in3(in_port),         
        .sel(c_MemToReg), .out(w_writeData_banco)
    );

    proxima_instrucao prox_pc (
        .pc_atual(pc_atual), .imediato(imm_ext), .reg_rs_dado(w_dado_rs),
        .branch(c_branch), .zero(flag_zero), .jump(c_jump), .jr_taken(c_jr_taken),
        .pc_novo(pc_novo), .pc_mais_1(pc_mais_1)
    );

endmodule
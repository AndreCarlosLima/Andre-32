module processador_fase2 (
    input clk,
    input reset,
    
    input regWrite, memtoread, memtowrite, isstack, push_en, pop_en,
    input branch, jump, jr_taken, ALUSrc,
    input [1:0] RegDst, MemToReg, SngExt,
    input [3:0] ULA_Ctrl,
    
    output [31:0] saida_resultado
);

    wire [31:0] instrucao, pc_atual, pc_novo, pc_mais_1;
    wire [31:0] w_dado_rs, w_dado_rt, w_ula_b, w_resultado_ula, w_dado_memoria, w_writeData_banco;
    wire [31:0] imm_ext, sp_atual;
    wire [4:0] w_writeReg;
    wire flag_zero;

    reg [31:0] pc_reg;
    assign pc_atual = pc_reg;
    always @(posedge clk) begin
        if (reset) pc_reg <= 32'b0;
        else pc_reg <= pc_novo;
    end

    Imem #(32, 8) imem (.addr(pc_atual[7:0]), .q(instrucao));

    wire [4:0] rs = instrucao[25:21];
    wire [4:0] rt = instrucao[20:16];
    wire [4:0] rd = instrucao[15:11];

    // ==========================================
    // MUX: REGDST
    // ==========================================
    mux4_5b mux_regdst (
        .in0(rt), .in1(rd), .in2(5'd31), .in3(5'd0),
        .sel(RegDst), .out(w_writeReg)
    );

    banco reg_file (
        .clk(clk), .regWrite(regWrite), .readReg1(rs), .readReg2(rt),
        .writeReg(w_writeReg), .writeData(w_writeData_banco),
        .readData1(w_dado_rs), .readData2(w_dado_rt)
    );

    extensor_sinal ext (.imm_in(instrucao[25:0]), .SngExt(SngExt), .imm_out(imm_ext));

    // ==========================================
    // MUX: ALUSRC
    // ==========================================
    mux2_32b mux_alusrc (
        .in0(w_dado_rt), .in1(imm_ext),
        .sel(ALUSrc), .out(w_ula_b)
    );

    ULA ula (.A(w_dado_rs), .B(w_ula_b), .Ctrl(ULA_Ctrl), .Result(w_resultado_ula), .Zero(flag_zero));

    gerenciador_pilha pilha (.clk(clk), .push(push_en), .pop(pop_en), .sp_out(sp_atual));

    Dmem #(32, 6) dmem (
        .clk(clk), .write_data(w_dado_rt), .addr_ula(w_resultado_ula), .addr_sp(sp_atual),
        .memtowrite(memtowrite), .memtoread(memtoread), .isstack(isstack), .read_data(w_dado_memoria)
    );

    proxima_instrucao prox_pc (
        .pc_atual(pc_atual), .imediato(imm_ext), .reg_rs_dado(w_dado_rs),
        .branch(branch), .zero(flag_zero), .jump(jump), .jr_taken(jr_taken),
        .pc_novo(pc_novo), .pc_mais_1(pc_mais_1)
    );

    // ==========================================
    // MUX: MEMTOREG
    // ==========================================
    mux4_32b mux_memtoreg (
        .in0(w_resultado_ula), .in1(w_dado_memoria), .in2(pc_mais_1), .in3(32'b0),
        .sel(MemToReg), .out(w_writeData_banco)
    );

    assign saida_resultado = w_resultado_ula;

endmodule
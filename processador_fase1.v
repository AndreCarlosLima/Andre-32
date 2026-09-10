module processador_fase1 (
    input clk,
    input reset,
    
    // Sinais de controle
    input regWrite,
    input memtowrite,
    input memtoread,
    input isstack,
    input ALUSrc,         // 1 bit: 0 = RT, 1 = Imediato
    input [1:0] MemToReg, // 2 bits: 00 = ULA, 01 = Memória
    input [3:0] ula_ctrl,
    input [31:0] imediato_teste,
    
    output [31:0] saida_resultado
);

    // Fios internos
    wire [31:0] instrucao;
    wire [31:0] w_dado_rs, w_dado_rt;
    wire [31:0] w_ula_b;
    wire [31:0] w_resultado_ula;
    wire [31:0] w_dado_memoria;
    wire [31:0] w_writeData_banco;
    wire flag_zero;

    // PC Básico para teste
    reg [7:0] pc;
    always @(posedge clk) begin
        if (reset) pc <= 8'b0;
        else pc <= pc + 1;
    end

    Imem #(32, 8) memoria_instrucao (.addr(pc), .q(instrucao));

    wire [4:0] rs = instrucao[25:21];
    wire [4:0] rt = instrucao[20:16];
    wire [4:0] rd = instrucao[15:11]; 

    banco meu_banco (
        .clk(clk), .regWrite(regWrite), .readReg1(rs), .readReg2(rt),
        .writeReg(rd), // Fixo no RD nesta fase inicial
        .writeData(w_writeData_banco), .readData1(w_dado_rs), .readData2(w_dado_rt)
    );

    // ==========================================
    // MUX: ALUSRC
    // ==========================================
    mux2_32b mux_alusrc (
        .in0(w_dado_rt), 
        .in1(imediato_teste), 
        .sel(ALUSrc), 
        .out(w_ula_b)
    );

    ULA minha_ula (
        .A(w_dado_rs), .B(w_ula_b), .Ctrl(ula_ctrl),
        .Result(w_resultado_ula), .Zero(flag_zero)
    );

    Dmem #(32, 6) memoria_dados (
        .clk(clk), .write_data(w_dado_rt), .addr_ula(w_resultado_ula), .addr_sp(32'd63),
        .memtowrite(memtowrite), .memtoread(memtoread), .isstack(isstack),
        .read_data(w_dado_memoria)
    );

    // ==========================================
    // MUX: MEMTOREG
    // ==========================================
    mux4_32b mux_memtoreg (
        .in0(w_resultado_ula), 
        .in1(w_dado_memoria), 
        .in2(32'b0), // Não usado na Fase 1
        .in3(32'b0), // Não usado na Fase 1
        .sel(MemToReg), 
        .out(w_writeData_banco)
    );

    assign saida_resultado = w_resultado_ula;

endmodule
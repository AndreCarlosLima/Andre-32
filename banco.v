module banco (
    input             clk,
    input             reset,      // NOVO: Reset físico
    input             regWrite,   
    input      [4:0]  readReg1,   
    input      [4:0]  readReg2,   
    input      [4:0]  writeReg,   
    input      [31:0] writeData,  
    output     [31:0] readData1,  
    output     [31:0] readData2   
);

    reg [31:0] registers [31:0];
    integer i; // Movido para cima para uso no always

    assign readData1 = (readReg1 == 5'b0) ? 32'b0 : registers[readReg1];
    assign readData2 = (readReg2 == 5'b0) ? 32'b0 : registers[readReg2];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Zera todos os registradores na reinicialização
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end
        else if (regWrite && writeReg != 5'b0) begin
            registers[writeReg] <= writeData;
        end
    end

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

endmodule
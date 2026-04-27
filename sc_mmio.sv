// =============================================================================
// sc_mmio.sv - CORRIGIDO para botões ativos em baixo (KEY ativo 0)
// =============================================================================

`timescale 1ns / 1ps

module sc_mmio (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        MemWrite,
    input  logic [1:0]  addr,
    input  logic [31:0] WriteData,

    input  logic [17:0] SW,
    input  logic [3:0]  KEY,          // KEYs são ativos em BAIXO! (1=solto, 0=apertado)

    output logic [31:0] ReadData,
    output logic [17:0] LEDR,
    output logic [8:0]  LEDG
);

    // -------------------------------------------------------------------------
    // Edge detection para botões ativos em baixo
    // Detecta borda de DESCIDA (1 → 0) = botão sendo pressionado
    // -------------------------------------------------------------------------
    logic [3:0] key_prev;
    logic [3:0] key_pressed;    // 1 por 1 ciclo quando botão é APERTADO

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_prev <= 4'b1111; 
        end else begin
            key_prev <= KEY;
        end
    end

    assign key_pressed = ~KEY & key_prev;

    // -------------------------------------------------------------------------
    // Read mux - retorna key_pressed, não KEY diretamente
    // -------------------------------------------------------------------------
    always_comb begin
        case (addr)
            2'b00:   ReadData = {14'b0, SW};
            2'b01:   ReadData = {28'b0, key_pressed};   // retorna borda de pressão
            default: ReadData = 32'b0;
        endcase
    end

    // -------------------------------------------------------------------------
    // LED write registers
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            LEDR <= 18'b0;
            LEDG <=  9'b0;
        end else if (MemWrite) begin
            case (addr)
                2'b10: LEDR <= WriteData[17:0];
                2'b11: LEDG <= WriteData[8:0];
                default: ;
            endcase
        end
    end

endmodule

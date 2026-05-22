// dual-port framebuffer 320x200, 12-bit rgb nibble-packed
module c64_fb_bram (
    input  logic        wr_clk,
    input  logic        wr_en,
    input  logic [15:0] wr_addr,
    input  logic [11:0] wr_data,

    input  logic        rd_clk,
    input  logic [15:0] rd_addr,
    output logic [11:0] rd_data
);
    (* ram_style = "block" *) logic [11:0] mem[0:63999];

    always_ff @(posedge wr_clk) begin
        if (wr_en)
            mem[wr_addr] <= wr_data;
    end

    always_ff @(posedge rd_clk) begin
        rd_data <= mem[rd_addr];
    end
endmodule

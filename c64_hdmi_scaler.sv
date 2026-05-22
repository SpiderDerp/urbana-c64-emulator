// read framebuffer, 2x upscale into 640x480 vga coordinates
module c64_hdmi_scaler #(
    parameter int FB_WIDTH  = 320,
    parameter int FB_HEIGHT = 200,
    parameter int BORDER_Y  = 40
) (
    input  logic        rd_clk,
    input  logic [9:0]  drawX,
    input  logic [9:0]  drawY,
    input  logic        vde,

    output logic        fb_rd_en,
    output logic [15:0] fb_rd_addr,
    input  logic [11:0] fb_rd_data,

    output logic [3:0]  red,
    output logic [3:0]  green,
    output logic [3:0]  blue
);
    logic in_c64;
    logic [8:0] c64_x;
    logic [7:0] c64_y;

    assign in_c64 = vde && (drawY >= BORDER_Y) && (drawY < BORDER_Y + FB_HEIGHT * 2);
    assign c64_x  = drawX[9:1];
    assign c64_y  = drawY[9:1] - BORDER_Y[8:1];

    assign fb_rd_en   = in_c64;
    assign fb_rd_addr = c64_y * FB_WIDTH + c64_x;

    always_comb begin
        if (in_c64) begin
            red   = fb_rd_data[11:8];
            green = fb_rd_data[7:4];
            blue  = fb_rd_data[3:0];
        end else begin
            red   = 4'h0;
            green = 4'h0;
            blue  = 4'h2;  // dark border
        end
    end
endmodule

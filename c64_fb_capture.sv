// capture vic rgb into framebuffer at clk/4 (~7.9mhz pixel rate)
module c64_fb_capture #(
    parameter int FB_WIDTH  = 320,
    parameter int FB_HEIGHT = 200
) (
    input  logic        clk,
    input  logic        reset,
    input  logic        vic_hblank,
    input  logic        vic_vblank,
    input  logic [7:0]  vic_r,
    input  logic [7:0]  vic_g,
    input  logic [7:0]  vic_b,
    output logic        fb_wr_en,
    output logic [15:0] fb_wr_addr,
    output logic [11:0] fb_wr_data
);
    logic [1:0] div;
    logic [8:0] pix_x;
    logic [7:0] pix_y;
    logic       vblank_d;
    logic       frame_start;

    assign fb_wr_data = {vic_r[7:4], vic_g[7:4], vic_b[7:4]};

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            div <= 0;
            pix_x <= 0;
            pix_y <= 0;
            vblank_d <= 0;
            fb_wr_en <= 0;
            fb_wr_addr <= 0;
        end else begin
            fb_wr_en <= 0;
            vblank_d <= vic_vblank;
            frame_start <= vic_vblank && !vblank_d;

            if (frame_start) begin
                pix_x <= 0;
                pix_y <= 0;
            end

            div <= div + 1'b1;
            if (div == 2'd3) begin
                div <= 0;
                if (!vic_hblank && !vic_vblank) begin
                    if (pix_x < FB_WIDTH && pix_y < FB_HEIGHT) begin
                        fb_wr_en   <= 1'b1;
                        fb_wr_addr <= pix_y * FB_WIDTH + pix_x;
                    end
                    if (pix_x == FB_WIDTH - 1) begin
                        pix_x <= 0;
                        if (pix_y < FB_HEIGHT - 1)
                            pix_y <= pix_y + 1'b1;
                    end else
                        pix_x <= pix_x + 1'b1;
                end
            end
        end
    end
endmodule

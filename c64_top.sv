// urbana c64 wrapper: fpga64 core + bram + hid + framebuffer hdmi path
module c64_top (
    input  logic        clk_usb,
    input  logic        clk_c64,
    input  logic        clk_vga,
    input  logic        reset,
    input  logic [31:0] keycode0,
    input  logic [31:0] keycode1,
    input  logic [9:0]  drawX,
    input  logic [9:0]  drawY,
    input  logic        vde,
    output logic [3:0]  red,
    output logic [3:0]  green,
    output logic [3:0]  blue
);
    logic [31:0] kc0_sync, kc1_sync;
    logic        c64_rst_n;
    logic [15:0] ram_addr;
    logic [7:0]  ram_din, ram_dout;
    logic        ram_ce, ram_we;

    logic [7:0]  vic_r, vic_g, vic_b;
    logic        vic_h, vic_v;

    logic [7:0]  k_pai, k_pao, k_pbi, k_pbo;
    logic [7:0]  joyA_bus, joyB_bus;
    logic [6:0]  joyA7, joyB7;

    logic        fb_wr_en;
    logic [15:0] fb_wr_addr, fb_rd_addr;
    logic [11:0] fb_wr_data, fb_rd_data;

    c64_key_sync u_sync (
        .clk_usb(clk_usb),
        .clk_c64(clk_c64),
        .reset(reset),
        .keycode0_in(keycode0),
        .keycode1_in(keycode1),
        .keycode0_out(kc0_sync),
        .keycode1_out(kc1_sync)
    );

    assign c64_rst_n = ~reset;

    assign joyA7 = joyA_bus[6:0];
    assign joyB7 = joyB_bus[6:0];

    c64_hid_matrix u_kbd (
        .clk(clk_c64),
        .reset(reset),
        .keycode0(kc0_sync),
        .keycode1(kc1_sync),
        .joyA(joyA_bus),
        .joyB(joyB_bus),
        .cia_pai(k_pai),
        .cia_pbi(k_pbi),
        .cia_pao(k_pao),
        .cia_pbo(k_pbo)
    );

    c64_memory u_ram (
        .clk(clk_c64),
        .ce(ram_ce),
        .we(ram_we),
        .addr(ram_addr),
        .din(ram_dout),   // core write data into ram
        .dout(ram_din)    // read back to core
    );

    c64_core_wrapper u_core (
        .clk32(clk_c64),
        .reset_n(c64_rst_n),
        .bios(2'b01),
        .ntscMode(1'b1),
        .vic_variant(2'b01),
        .palette(3'b000),
        .joyA(joyA7),
        .joyB(joyB7),
        .ext_kbd_pai(k_pai),
        .ext_kbd_pao(k_pao),
        .ext_kbd_pbi(k_pbi),
        .ext_kbd_pbo(k_pbo),
        .ramAddr(ram_addr),
        .ramDout(ram_dout),
        .ramDin(ram_din),
        .ramCE(ram_ce),
        .ramWE(ram_we),
        .hsync(vic_h),
        .vsync(vic_v),
        .r(vic_r),
        .g(vic_g),
        .b(vic_b)
    );

    c64_fb_capture u_cap (
        .clk(clk_c64),
        .reset(reset),
        .vic_hblank(vic_h),
        .vic_vblank(vic_v),
        .vic_r(vic_r),
        .vic_g(vic_g),
        .vic_b(vic_b),
        .fb_wr_en(fb_wr_en),
        .fb_wr_addr(fb_wr_addr),
        .fb_wr_data(fb_wr_data)
    );

    c64_fb_bram u_fb (
        .wr_clk(clk_c64),
        .wr_en(fb_wr_en),
        .wr_addr(fb_wr_addr),
        .wr_data(fb_wr_data),
        .rd_clk(clk_vga),
        .rd_addr(fb_rd_addr),
        .rd_data(fb_rd_data)
    );

    c64_hdmi_scaler u_scale (
        .rd_clk(clk_vga),
        .drawX(drawX),
        .drawY(drawY),
        .vde(vde),
        .fb_rd_en(),
        .fb_rd_addr(fb_rd_addr),
        .fb_rd_data(fb_rd_data),
        .red(red),
        .green(green),
        .blue(blue)
    );

endmodule

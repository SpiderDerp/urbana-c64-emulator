//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    zuofu cheng / c64 emulator extension                               --
//-------------------------------------------------------------------------

module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,

    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,

    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,

    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0] hdmi_tmds_data_n,
    output logic [2:0] hdmi_tmds_data_p,

    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);

    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk_c64;
    logic locked_hdmi, locked_c64, locked_all;
    logic [9:0] drawX, drawY;
    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    logic c64_reset;
    logic [23:0] rst_cnt;

    assign reset_ah = reset_rtl_0;
    assign locked_all = locked_hdmi & locked_c64;

    // hold c64 in reset ~1ms after mmcm lock
    always_ff @(posedge Clk) begin
        if (!locked_all || reset_ah)
            rst_cnt <= 0;
        else if (rst_cnt < 24'd100_000)
            rst_cnt <= rst_cnt + 1'b1;
    end
    assign c64_reset = reset_ah || !locked_all || (rst_cnt < 24'd100_000);

    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[31:28], keycode0_gpio[27:24], keycode0_gpio[23:20], keycode0_gpio[19:16]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );

    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );

    mb_usb mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );

    // hdmi: 25mhz + 125mhz
    clk_wiz_0 clk_wiz_hdmi (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked_hdmi),
        .clk_in1(Clk)
    );

    // c64 system clock ~31.528mhz ntsc (create as clk_wiz_c64 in vivado)
    clk_wiz_c64 clk_wiz_c64_i (
        .clk_out1(clk_c64),
        .reset(reset_ah),
        .locked(locked_c64),
        .clk_in1(Clk)
    );

    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );

    c64_top u_c64 (
        .clk_usb(Clk),
        .clk_c64(clk_c64),
        .clk_vga(clk_25MHz),
        .reset(c64_reset),
        .keycode0(keycode0_gpio),
        .keycode1(keycode1_gpio),
        .drawX(drawX),
        .drawY(drawY),
        .vde(vde),
        .red(red),
        .green(green),
        .blue(blue)
    );

    hdmi_tx_0 vga_to_hdmi (
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked_hdmi),
        .rst(reset_ah),
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        .TMDS_CLK_P(hdmi_tmds_clk_p),
        .TMDS_CLK_N(hdmi_tmds_clk_n),
        .TMDS_DATA_P(hdmi_tmds_data_p),
        .TMDS_DATA_N(hdmi_tmds_data_n)
    );

endmodule

// cdc: usb gpio keycodes from 100mhz mb domain into c64 clock
module c64_key_sync (
    input  logic        clk_usb,
    input  logic        clk_c64,
    input  logic        reset,
    input  logic [31:0] keycode0_in,
    input  logic [31:0] keycode1_in,
    output logic [31:0] keycode0_out,
    output logic [31:0] keycode1_out
);
    logic [31:0] k0_a, k0_b, k1_a, k1_b;

    always_ff @(posedge clk_usb or posedge reset) begin
        if (reset) begin
            k0_a <= 0;
            k1_a <= 0;
        end else begin
            k0_a <= keycode0_in;
            k1_a <= keycode1_in;
        end
    end

    always_ff @(posedge clk_c64 or posedge reset) begin
        if (reset) begin
            k0_b <= 0;
            k1_b <= 0;
            keycode0_out <= 0;
            keycode1_out <= 0;
        end else begin
            k0_b <= k0_a;
            k1_b <= k1_a;
            keycode0_out <= k0_b;
            keycode1_out <= k1_b;
        end
    end
endmodule

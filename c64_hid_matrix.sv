// usb hid to c64 cia1 keyboard matrix + port 1 joystick
module c64_hid_matrix (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] keycode0,
    input  logic [31:0] keycode1,
    output logic [7:0]  joyA,
    output logic [7:0]  joyB,
    input  logic [7:0]  cia_pai,
    input  logic [7:0]  cia_pbi,
    output logic [7:0]  cia_pao,
    output logic [7:0]  cia_pbo
);
    logic key_del, key_return, key_left, key_right;
    logic key_F1, key_F3, key_F5, key_F7;
    logic key_up, key_down;
    logic key_3, key_W, key_A, key_4, key_Z, key_S, key_E, key_shiftl;
    logic key_5, key_R, key_D, key_6, key_C, key_F, key_T, key_X;
    logic key_7, key_Y, key_G, key_8, key_B, key_H, key_U, key_V;
    logic key_9, key_I, key_J, key_0, key_M, key_K, key_O, key_N;
    logic key_plus, key_P, key_L, key_minus, key_dot, key_colon, key_at, key_comma;
    logic key_pound, key_star, key_semicolon, key_home, key_shiftr, key_equal;
    logic key_arrowup, key_slash, key_1, key_arrowleft, key_ctrl, key_2;
    logic key_space, key_commodore, key_Q, key_runstop;

    logic [7:0] keys [0:5];
    logic [7:0] mod_byte;

    assign keys[0] = keycode0[7:0];
    assign keys[1] = keycode0[15:8];
    assign keys[2] = keycode0[23:16];
    assign keys[3] = keycode0[31:24];
    assign keys[4] = keycode1[7:0];
    assign keys[5] = keycode1[15:8];
    assign mod_byte = keycode1[23:16];

    function automatic logic key_hit(input logic [7:0] code);
        logic hit;
        hit = 0;
        for (int i = 0; i < 6; i++)
            if (keys[i] == code && code != 8'h00)
                hit = 1;
        return hit;
    endfunction

    always_comb begin
        key_del       = key_hit(8'h2A);
        key_return    = key_hit(8'h28);
        key_left      = key_hit(8'h50);
        key_right     = key_hit(8'h4F);
        key_up        = key_hit(8'h52);
        key_down      = key_hit(8'h51);
        key_F1        = key_hit(8'h3A);
        key_F3        = key_hit(8'h3C);
        key_F5        = key_hit(8'h3E);
        key_F7        = key_hit(8'h40);
        key_1         = key_hit(8'h1E);
        key_2         = key_hit(8'h1F);
        key_3         = key_hit(8'h20);
        key_4         = key_hit(8'h21);
        key_5         = key_hit(8'h22);
        key_6         = key_hit(8'h23);
        key_7         = key_hit(8'h24);
        key_8         = key_hit(8'h25);
        key_9         = key_hit(8'h26);
        key_0         = key_hit(8'h27);
        key_Q         = key_hit(8'h14);
        key_W         = key_hit(8'h1A);
        key_E         = key_hit(8'h08);
        key_R         = key_hit(8'h15);
        key_T         = key_hit(8'h17);
        key_Y         = key_hit(8'h1C);
        key_U         = key_hit(8'h18);
        key_I         = key_hit(8'h0C);
        key_O         = key_hit(8'h12);
        key_P         = key_hit(8'h13);
        key_A         = key_hit(8'h04);
        key_S         = key_hit(8'h16);
        key_D         = key_hit(8'h07);
        key_F         = key_hit(8'h09);
        key_G         = key_hit(8'h0A);
        key_H         = key_hit(8'h0B);
        key_J         = key_hit(8'h0D);
        key_K         = key_hit(8'h0E);
        key_L         = key_hit(8'h0F);
        key_Z         = key_hit(8'h1D);
        key_X         = key_hit(8'h1B);
        key_C         = key_hit(8'h06);
        key_V         = key_hit(8'h19);
        key_B         = key_hit(8'h05);
        key_N         = key_hit(8'h11);
        key_M         = key_hit(8'h10);
        key_space     = key_hit(8'h2C);
        key_minus     = key_hit(8'h2D);
        key_equal     = key_hit(8'h2E);
        key_semicolon = key_hit(8'h33);
        key_comma     = key_hit(8'h36);
        key_dot       = key_hit(8'h37);
        key_slash     = key_hit(8'h38);
        key_shiftl    = mod_byte[0] | mod_byte[4];
        key_shiftr    = mod_byte[1] | mod_byte[5];
        key_ctrl      = mod_byte[0] | mod_byte[4];
        key_commodore = 0;
        key_runstop   = key_hit(8'h29);
        key_home      = 0;
        key_star      = 0;
        key_pound     = 0;
        key_colon     = key_hit(8'h34);
        key_at        = 0;
        key_plus      = key_equal;
        key_arrowleft = 0;
        key_arrowup   = 0;
        key_L         = key_hit(8'h0F);
    end

    // port 1 joystick: 0 = pressed
    assign joyA = {
        ~key_space,
        1'b1,
        ~key_D,
        ~key_A,
        ~key_down,
        ~key_up
    };
    assign joyB = 8'hFF;

    always_comb begin
        cia_pao[0] = cia_pai[0] &
            ((cia_pbi[0] | !key_del) & (cia_pbi[1] | !key_return) &
             (cia_pbi[2] | !key_left) & (cia_pbi[3] | !key_F7) &
             (cia_pbi[4] | !key_F1) & (cia_pbi[5] | !key_F3) &
             (cia_pbi[6] | !key_F5) & (cia_pbi[7] | !key_up));
        cia_pao[1] = cia_pai[1] &
            ((cia_pbi[0] | !key_3) & (cia_pbi[1] | !key_W) & (cia_pbi[2] | !key_A) &
             (cia_pbi[3] | !key_4) & (cia_pbi[4] | !key_Z) & (cia_pbi[5] | !key_S) &
             (cia_pbi[6] | !key_E) & (cia_pbi[7] | !key_shiftl));
        cia_pao[2] = cia_pai[2] &
            ((cia_pbi[0] | !key_5) & (cia_pbi[1] | !key_R) & (cia_pbi[2] | !key_D) &
             (cia_pbi[3] | !key_6) & (cia_pbi[4] | !key_C) & (cia_pbi[5] | !key_F) &
             (cia_pbi[6] | !key_T) & (cia_pbi[7] | !key_X));
        cia_pao[3] = cia_pai[3] &
            ((cia_pbi[0] | !key_7) & (cia_pbi[1] | !key_Y) & (cia_pbi[2] | !key_G) &
             (cia_pbi[3] | !key_8) & (cia_pbi[4] | !key_B) & (cia_pbi[5] | !key_H) &
             (cia_pbi[6] | !key_U) & (cia_pbi[7] | !key_V));
        cia_pao[4] = cia_pai[4] &
            ((cia_pbi[0] | !key_9) & (cia_pbi[1] | !key_I) & (cia_pbi[2] | !key_J) &
             (cia_pbi[3] | !key_0) & (cia_pbi[4] | !key_M) & (cia_pbi[5] | !key_K) &
             (cia_pbi[6] | !key_O) & (cia_pbi[7] | !key_N));
        cia_pao[5] = cia_pai[5] &
            ((cia_pbi[0] | !key_plus) & (cia_pbi[1] | !key_P) & (cia_pbi[2] | !key_L) &
             (cia_pbi[3] | !key_minus) & (cia_pbi[4] | !key_dot) & (cia_pbi[5] | !key_colon) &
             (cia_pbi[6] | !key_at) & (cia_pbi[7] | !key_comma));
        cia_pao[6] = cia_pai[6] &
            ((cia_pbi[0] | !key_pound) & (cia_pbi[1] | !key_star) &
             (cia_pbi[2] | !key_semicolon) & (cia_pbi[3] | !key_home) &
             (cia_pbi[4] | !key_shiftr) & (cia_pbi[5] | !key_equal) &
             (cia_pbi[6] | !key_arrowup) & (cia_pbi[7] | !key_slash));
        cia_pao[7] = cia_pai[7] &
            ((cia_pbi[0] | !key_1) & (cia_pbi[1] | !key_arrowleft) &
             (cia_pbi[2] | !key_ctrl) & (cia_pbi[3] | !key_2) &
             (cia_pbi[4] | !key_space) & (cia_pbi[5] | !key_commodore) &
             (cia_pbi[6] | !key_Q) & (cia_pbi[7] | !key_runstop));

        cia_pbo[0] = cia_pbi[0] & joyA[0] &
            ((cia_pai[0] | !key_del) & (cia_pai[1] | !key_3) & (cia_pai[2] | !key_5) &
             (cia_pai[3] | !key_7) & (cia_pai[4] | !key_9) & (cia_pai[5] | !key_plus) &
             (cia_pai[6] | !key_pound) & (cia_pai[7] | !key_1));
        cia_pbo[1] = cia_pbi[1] & joyA[1] &
            ((cia_pai[0] | !key_return) & (cia_pai[1] | !key_W) & (cia_pai[2] | !key_R) &
             (cia_pai[3] | !key_Y) & (cia_pai[4] | !key_I) & (cia_pai[5] | !key_P) &
             (cia_pai[6] | !key_star) & (cia_pai[7] | !key_arrowleft));
        cia_pbo[2] = cia_pbi[2] & joyA[2] &
            ((cia_pai[0] | !key_left) & (cia_pai[1] | !key_A) & (cia_pai[2] | !key_D) &
             (cia_pai[3] | !key_G) & (cia_pai[4] | !key_J) & (cia_pai[5] | !key_L) &
             (cia_pai[6] | !key_semicolon) & (cia_pai[7] | !key_ctrl));
        cia_pbo[3] = cia_pbi[3] & joyA[3] &
            ((cia_pai[0] | !key_F7) & (cia_pai[1] | !key_4) & (cia_pai[2] | !key_6) &
             (cia_pai[3] | !key_8) & (cia_pai[4] | !key_0) & (cia_pai[5] | !key_minus) &
             (cia_pai[6] | !key_home) & (cia_pai[7] | !key_2));
        cia_pbo[4] = cia_pbi[4] & joyA[4] &
            ((cia_pai[0] | !key_F1) & (cia_pai[1] | !key_Z) & (cia_pai[2] | !key_C) &
             (cia_pai[3] | !key_B) & (cia_pai[4] | !key_M) & (cia_pai[5] | !key_dot) &
             (cia_pai[6] | !key_shiftr) & (cia_pai[7] | !key_space));
        cia_pbo[5] = cia_pbi[5] &
            ((cia_pai[0] | !key_F3) & (cia_pai[1] | !key_S) & (cia_pai[2] | !key_F) &
             (cia_pai[3] | !key_H) & (cia_pai[4] | !key_K) & (cia_pai[5] | !key_colon) &
             (cia_pai[6] | !key_equal) & (cia_pai[7] | !key_commodore));
        cia_pbo[6] = cia_pbi[6] &
            ((cia_pai[0] | !key_F5) & (cia_pai[1] | !key_E) & (cia_pai[2] | !key_T) &
             (cia_pai[3] | !key_U) & (cia_pai[4] | !key_O) & (cia_pai[5] | !key_at) &
             (cia_pai[6] | !key_arrowup) & (cia_pai[7] | !key_Q));
        cia_pbo[7] = cia_pbi[7] &
            ((cia_pai[0] | !key_up) & (cia_pai[1] | !key_shiftl) & (cia_pai[2] | !key_X) &
             (cia_pai[3] | !key_V) & (cia_pai[4] | !key_N) & (cia_pai[5] | !key_comma) &
             (cia_pai[6] | !key_slash) & (cia_pai[7] | !key_runstop));
    end

endmodule

// 64kb c64 ram, dual-port (c64 core + optional debug)
module c64_memory #(
    parameter string RAM_HEX = "c64/roms/games/default_ram.hex"
) (
    input  logic        clk,
    input  logic        ce,
    input  logic        we,
    input  logic [15:0] addr,
    input  logic [7:0]  din,
    output logic [7:0]  dout
);
    (* ram_style = "block" *) logic [7:0] mem[0:65535];

    initial begin
        integer i;
        for (i = 0; i < 65536; i++)
            mem[i] = 8'h00;
        $readmemh(RAM_HEX, mem);
    end

    always_ff @(posedge clk) begin
        if (ce) begin
            if (we)
                mem[addr] <= din;
            dout <= mem[addr];  // read on same cycle as write-first
        end
    end
endmodule

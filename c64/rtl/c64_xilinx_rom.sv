// block rom for kernal/chargen (vivado readmemh init)
module c64_xilinx_rom #(
    parameter int ADDR_WIDTH = 14,
    parameter string HEX_FILE = "std_C64.hex"
) (
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] rdaddress,
    output logic [7:0]            q,
    input  logic                  wren,
    input  logic [ADDR_WIDTH-1:0] wraddress,
    input  logic [7:0]            data
);
    localparam int DEPTH = 1 << ADDR_WIDTH;

    (* rom_style = "block" *) logic [7:0] mem[0:DEPTH-1];

    initial begin
        $readmemh(HEX_FILE, mem);
    end

    always_ff @(posedge clk) begin
        if (wren)
            mem[wraddress] <= data;
        q <= mem[rdaddress];
    end
endmodule

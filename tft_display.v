module tft_display(
							input clk,
							input rst_n,
							
							input [10:0]	hcount,
							input [10:0]	vcount,
							
							input 			q,
							
							output [15:0]	vga_data,
							
							output [18:0]  address
);	


	
`define RED      24'hff0000
`define GREEN    24'h00ff00
`define BLUE     24'h0000ff
`define WHITE    24'hffffff
`define BLACK    24'h000000
`define YELLOW   24'hffff00
`define CYAN     24'hff00ff
`define ROYAL    24'h00ffff


assign address =  hcount[10:0] + vcount[10:0]*800;
assign vga_data = {q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q};

	
endmodule 
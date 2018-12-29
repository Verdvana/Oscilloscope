module data_process
(
							input    clk,
							input    clk_adc_dout_0,
							input    clk_data_rst_n,
							input    rst_n,
							output   clk_data_process,
							
							input [11:0]   dout_0,
							
							output  reg    write_enable=0,
							
							output  reg       data_rst_n=0,
							output [18:0]  z
														
							
);

reg [19:0] cnt; 

reg [19:0] address;

wire data_rst_n_2;

assign data_rst_n_2=data_rst_n & write_enable;

assign clk_data_process = data_rst_n ? (data_rst_n_2?clk_data_rst_n:clk):clk_adc_dout_0;

always@(posedge clk_data_process or negedge rst_n)
begin
	if(!rst_n)
		cnt<=20'b0;
	
	else if(cnt==20'd768799)
		cnt<=20'b0;
	
	else 
		cnt<=cnt+1'b1;
		
end

always@(posedge clk_data_process or negedge rst_n)
begin
	if(!rst_n)
		address<=19'b0;
	
	else if(cnt==20'd383999)
		address<=19'b0;
	
	else if(cnt>=20'd384799)
		address<=19'b0;
	
	else 
		address<=address+1'b1;
		
end

always@(posedge clk_data_process or negedge rst_n)
begin
	if(!rst_n)
		data_rst_n<=1'b0;
	
	else if(cnt>=20'd383999&&cnt<=20'd384799)
		data_rst_n<=1'b0;
	
	else 
		data_rst_n<=1'b1;
	
end

always@(posedge clk_data_process or negedge rst_n)
begin
	if(!rst_n)
		write_enable<=1'b0;
	
	else if(cnt<=19'd384799)
		write_enable<=1'b1;
	
	else 
		write_enable<=1'b0;

end

assign z = (data_rst_n )?(address ): ( 17'd101600 + address - dout_0[11:5]*800);

endmodule


module tft_driver(
							input clk,    //33.3M
							input rst_n,
							input [15:0] data_in,   //待显示数据
							
							output [10:0] hcount,
							output [10:0] vcount,
							output [15:0] tft_rgb,   //TFT数据输出
							output tft_hsync,
							output tft_vsync,
							output tft_clk,
							output tft_blank_n,
							output tft_pwm

);

	
	
	reg [10:0] hcount_r;   //TFT行扫描计数器
	reg [10:0] vcount_r;		//TFT场扫描计数器
	
	wire hcount_ov;
	wire vcount_ov;
	wire dat_act;  //有效显示区标定
	
	//TFT行、场扫描时序参数表
	parameter 
		tft_hsync_end 		=11'd1,
		hdat_begin 		=11'd46,
		hdat_end			=11'd846,
		hpixel_end		=11'd1056,
		tft_vsync_end		=11'd1,
		vdat_begin		=11'd24,
		vdat_end			=11'd504,
		vline_end		=11'd524;
		
	assign hcount=dat_act ? (hcount_r-hdat_begin):11'd0;
	assign vcount=dat_act ? (vcount_r-vdat_begin):11'd0;
	
	assign tft_clk=clk;
	assign tft_blank_n=dat_act;
	assign tft_pwm=rst_n;
	
	//TFT驱动部分
	//行扫扫描
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		hcount_r<=11'd0;
	else if(hcount_ov)
		hcount_r<=11'd0;
	else
		hcount_r<=hcount_r+11'd1;
		
	assign hcount_ov=(hcount_r==hpixel_end);
	
	//场扫描
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		vcount_r<=11'd0;
	else if(hcount_ov)
		begin
		if(vcount_ov)
		vcount_r<=11'd0;
		else
		vcount_r<=vcount_r+11'd1;
		end
	else
		vcount_r<=vcount_r;
		
	assign vcount_ov=(vcount_r==vline_end);
	
	//数据、同频信号输出
	assign dat_act=((hcount_r>=hdat_begin)&&(hcount_r<hdat_end))
						&&((vcount_r>=vdat_begin)&&(vcount_r<vdat_end));
	assign tft_hsync=(hcount_r>tft_hsync_end);
	assign tft_vsync=(vcount_r>tft_vsync_end);
	assign tft_rgb=(dat_act)?data_in:16'h0000;
	
endmodule
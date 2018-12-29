module AD7928(
					input                clk,
					input                rst_n,
					output reg [11:0]    dout_0,         //并行输出
					output reg [11:0]    dout_1,
					output reg [11:0]    dout_2,
					output reg [11:0]    dout_3,
					output reg [11:0]    dout_4,
					output reg [11:0]    dout_5,
					output reg [11:0]    dout_6,
					output reg [11:0]    dout_7,
					output reg [7:0]     dout_vld,     //数据有效信号，1为有效
					

					
					input                adc_dout,     //adc输出（串行）
					output reg           adc_din,      //adc输入
					output reg           adc_sclk,     //adc时钟
					output reg           adc_cs_n      //adc片选信号
);



//---------------------------------
//主计数器
reg [5:0]   cnt0;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
		begin
			cnt0 <= 0;
		end
		
    else if(cnt0 == 37)
		begin 	 
        cnt0 <= 0;
		end
		
    else
        cnt0 <= cnt0 + 1'b1;
end 
//---------------------------------



//----------------------------------
//CS信号
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
		begin
			adc_cs_n <= 1;
		end
		
    else if(cnt0 == 2)
		begin 	 
        adc_cs_n <= 0;
		end
	
	else if(cnt0 == 35)
		begin 	 
        adc_cs_n <= 1;
		end

end 
//----------------------------------


//----------------------------------
//SCLK信号
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
		begin
			adc_sclk <= 1;
		end
		
    else if(cnt0==3 | cnt0==5 | cnt0==7 | cnt0==9 | cnt0==11 | cnt0==13 | cnt0==15 | cnt0==17 | cnt0==19 | cnt0==21 | cnt0==23 | cnt0==25 | cnt0==27 | cnt0==29 | cnt0==31 | cnt0==33)
		begin 	 
        adc_sclk <= 0;
		end
	
	 else if(cnt0==4 | cnt0==6 | cnt0==8 | cnt0==10 | cnt0==12 | cnt0==14 | cnt0==16 | cnt0==18 | cnt0==20 | cnt0==22 | cnt0==24 | cnt0==26 | cnt0==28 | cnt0==30 | cnt0==32 | cnt0==34)
		begin 	 
        adc_sclk <= 1;
		end
end 
//----------------------------------


//---------------------------------------------
//地址计数器
reg [2:0]  cnt_address;

reg cs_n;
reg cs_n_wrsigrise;
//检测adc_cs_n上升沿
always@(posedge clk)
begin
	cs_n <=  adc_cs_n;
	cs_n_wrsigrise <= (!cs_n) & adc_cs_n;
end


always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
        cnt_address <= 0;
		end
	
	else if(cs_n_wrsigrise)
		if(cnt_address==3'b001)//3'b111
			begin
				cnt_address <= 0;
			end
		
		else
			begin
				cnt_address <= cnt_address + 1;
			end	
end
//---------------------------------------------  


//---------------------------------------------
//串行输出给adc
parameter  WRITE  = 1'b1;
parameter  PM     = 2'b11;
parameter  SEQ    = 1'b0;
parameter  SHADOW = 1'b0;
parameter  RANGE  = 1'b0;
parameter  CODING = 1'b1;

wire   [15:0]   data;

assign data ={WRITE,SEQ,1'b0,cnt_address,PM,SHADOW,1'b0,RANGE,CODING,4'b0000};   //00001000011XXX001

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
        adc_din <= 0;
		end
	
	else
		begin
			case(cnt0)
				6'b000010:adc_din = data[15];
				6'b000100:adc_din = data[14];
				6'b000110:adc_din = data[13];
				6'b001000:adc_din = data[12];
				6'b001010:adc_din = data[11];
				6'b001100:adc_din = data[10];
				6'b001110:adc_din = data[9];
				6'b010000:adc_din = data[8];
				6'b010010:adc_din = data[7];
				6'b010100:adc_din = data[6];
				6'b010110:adc_din = data[5];
				6'b011000:adc_din = data[4];
				6'b011010:adc_din = data[3];
				6'b011100:adc_din = data[2];
				6'b011110:adc_din = data[1];
				6'b100000:adc_din = data[0];
				//default: adc_din = 0;
			endcase
		end

end

//----------------------------------------------

//串转并
reg [14:0] dout ;

reg [4:0]cnt1;  //计sclk的个数 0-16
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		cnt1<=0;
	
	else if(adc_sclk && adc_cs_n==0)
		if(cnt1==16)
			cnt1<=0;
	
		else
			cnt1<=cnt1+1;
end


always@(posedge clk or negedge rst_n )
begin
	if(!rst_n)
		dout <= 0;
		
	else if (cnt0==1 )
		dout <= 0;
		
	else if ( cnt1<16 )	
		dout[15-cnt1] <= adc_dout;
		
end
//----------------------------------------------


//----------------------------------------------
//输出
always@(posedge adc_cs_n or negedge rst_n)
begin 
	if(!rst_n)
		begin
			dout_0<=0;
			dout_1<=0;
			dout_2<=0;
			dout_3<=0;
			dout_4<=0;
			dout_5<=0;
			dout_6<=0;
			dout_7<=0;
		end
	else 
		begin
			case (dout[14:12])
				3'b000: dout_0<=dout[11:0];
				3'b001: dout_1<=dout[11:0];
				3'b010: dout_2<=dout[11:0];
				3'b011: dout_3<=dout[11:0];
				3'b100: dout_4<=dout[11:0];
				3'b101: dout_5<=dout[11:0];
				3'b110: dout_6<=dout[11:0];
				3'b111: dout_7<=dout[11:0];		
				default: 
					begin
						dout_0<=0;
						dout_1<=0;
						dout_2<=0;
						dout_3<=0;
						dout_4<=0;
						dout_5<=0;
						dout_6<=0;
						dout_7<=0;
					end
			endcase
		end
end

//----------------------------------------------

always@(posedge clk or negedge rst_n)
begin 
	if(!rst_n)
		begin
			dout_vld<=8'b0000_0000;
		end
	else if( cs_n_wrsigrise ==1)
		begin
			case (dout[14:12])
				3'b000: dout_vld<=8'b00000001;
				3'b001: dout_vld<=8'b00000010;
				3'b010: dout_vld<=8'b00000100;
				3'b011: dout_vld<=8'b00001000;
				3'b100: dout_vld<=8'b00010000;
				3'b101: dout_vld<=8'b00100000;
				3'b110: dout_vld<=8'b01000000;
				3'b111: dout_vld<=8'b10000000;		
				default:dout_vld<=8'b00000000;		
			endcase
		end
		
	else
		dout_vld<=8'b00000000;
end

endmodule
`timescale 1ns / 1ps

module finalpicture (clk,rst, hsync, vsync, vga_r, vga_g, vga_b, mode, s0, s1, s3, s4, s2, en_ssl,en_ssr, ssl,ssr, led,ps2_clk,ps2_data);
input clk,rst, mode, s0, s1, s3, s4, s2,ps2_clk,ps2_data;
output reg [3:0]en_ssl,en_ssr;
output reg[7:0]ssl,ssr;
output reg [15:0]led;
//// monitor
output hsync,vsync;
output [3:0]vga_r, vga_g, vga_b;
wire pclk;
wire valid;
wire [9:0]h_cnt,v_cnt;
reg [11:0]vga_data;
wire [11:0]rom_dout_e,rom_dout_e1, rom_dout_e2, rom_dout_q, rom_dout_q1, rom_dout_r, rom_dout_w, rom_dout_w0, rom_dout_a, rom_dout_q0, rom_dout_a1, rom_dout_a2, rom_dout_d, rom_dout_s, rom_dout_e0, rom_dout_s1, rom_dout_s2, rom_dout_f, rom_dout_r0, rom_dout_f1;
reg [12:0]rom_addr_e,rom_addr_e1, rom_addr_e2, rom_addr_q, rom_addr_q1, rom_addr_r, rom_addr_w, rom_addr_w0, rom_addr_a, rom_addr_q0, rom_addr_a1, rom_addr_a2, rom_addr_d, rom_addr_f,rom_addr_e0, rom_addr_f1, rom_addr_s, rom_addr_r0, rom_addr_s1, rom_addr_s2;  //2^13=8192
wire a, b, c, d, e, f, g, h, ii, jj, k, l, m, n, o; //vertical and horizontal line
reg [9:0] ex, ey, qx, qy, rx, ry, wx, wy, ax, ay, sx, sy, dx, dy,r0x, r0y, fx, fy, q0x, q0y, a1x, a2x, a1y, a2y,w0x, w0y, s1x, s1y, s2x, s2y,e0x, e0y, f1x, f1y, q1x, q1y, e1x, e1y, e2x, e2y;  //字母的x, y座標
reg q0_area, w0_area, e0_area, r0_area, r_area, e_area, q_area, w_area, a_area, s_area, d_area, f_area, a1_area, a2_area, s1_area, s2_area, f1_area, q1_area, e1_area, e2_area;
reg [3:0]delete;
parameter da=1,ds=2, dd=3, df=4, dq=5, dw=6, de=7, dr=8;
/// FPGA
reg counter_ssl,clk_seg,clk_segr,clk_led;
reg [26:0]counter26;
reg [1:0]counter_life;
reg [1:0]life,counter_ssr;
reg Q,W,E,R,A,S,D,F,start;/////////按鍵輸入後的訊號
reg [1:0]cs,ns;
reg [4:0]counter_led;
reg [31:0] timerR,timerW,timerE,timerQ;///////按下fpga按鍵時間
reg stateR,stateW,stateE,stateQ;//////fpga按鍵狀態
reg ps2state_reg;
wire flag;//為1時 輸出 內部訊號
reg ps2_loosen;////為1時 清除按鍵訊號
reg [7:0]ps2_byte;
reg [3:0]num; //移位控制
reg [7:0]data_temp;///接收ps2_data
reg ps2_clk0, ps2_clk1, ps2_clk2;
wire ps2_clk_neg;
reg ps2_state;///鍵盤按鍵狀態
reg[31:0]counterA,counterS,counterD,counterF,counterQ,counterW,counterE,counterR;//////計數按鍵按了幾次
reg[31:0] counters2,i,j;///////s2(start)按鍵的debouncing , i = 答對記數 , j = 答錯記數
parameter stop = 2'b00,run = 2'b01,win = 2'b10,die = 2'b11;//////遊戲的狀態

/////////////////////////////////////monitor//////////////////////////////////////////by 蔡瑩靜
///add picture and call ''sync generation'' module
dcm_25m u0(.clk_in1(clk), .clk_out1(pclk), .reset(!rst));
e u1(.clka(pclk), .addra(rom_addr_e), .douta(rom_dout_e));
e u2(.clka(pclk), .addra(rom_addr_e1), .douta(rom_dout_e1));
e u3(.clka(pclk), .addra(rom_addr_e2), .douta(rom_dout_e2));      
q u4(.clka(pclk), .addra(rom_addr_q), .douta(rom_dout_q));
q u5(.clka(pclk), .addra(rom_addr_q1), .douta(rom_dout_q1));
r u6(.clka(pclk), .addra(rom_addr_r), .douta(rom_dout_r));      
w u7(.clka(pclk), .addra(rom_addr_w), .douta(rom_dout_w));
a u8(.clka(pclk), .addra(rom_addr_a), .douta(rom_dout_a));
w u9(.clka(pclk), .addra(rom_addr_w0), .douta(rom_dout_w0));     
a u10(.clka(pclk), .addra(rom_addr_a1), .douta(rom_dout_a1));  
a u11(.clka(pclk), .addra(rom_addr_a2), .douta(rom_dout_a2));
s u12(.clka(pclk), .addra(rom_addr_s), .douta(rom_dout_s));	
r u13(.clka(pclk), .addra(rom_addr_r0), .douta(rom_dout_r0));		
s u14(.clka(pclk), .addra(rom_addr_s1), .douta(rom_dout_s1));		
s u15(.clka(pclk), .addra(rom_addr_s2), .douta(rom_dout_s2));		   
d u16(.clka(pclk), .addra(rom_addr_d), .douta(rom_dout_d));		
e u17(.clka(pclk), .addra(rom_addr_e0), .douta(rom_dout_e0));		
f u18(.clka(pclk), .addra(rom_addr_f), .douta(rom_dout_f));
q u19(.clka(pclk), .addra(rom_addr_q0), .douta(rom_dout_q0));
f u20(.clka(pclk), .addra(rom_addr_f1), .douta(rom_dout_f1));
SyncGeneration u21 (.pclk(pclk), .reset(!rst), .hSync(hsync), .vSync(vsync), .dataValid(valid), .hDataCnt(h_cnt), .vDataCnt(v_cnt));
////////////////////////////mode==1/////////////////////////////////////
always@(*)begin ////////////delete  r
    case(mode)
    1:begin
        if (i>0) r_area=0;
        else if ((v_cnt>=ry)&(v_cnt<=ry+69)&(h_cnt>=rx)&(h_cnt<=rx+69))r_area =1;
        else r_area=0;end
    0: begin  r_area=0;end
    endcase
end

always@(*)begin ///////////////delete e
    case(mode)
    1:begin        
        if (i>1) e_area=0;
        else if ((v_cnt>=ey)&(v_cnt<=ey+69)&(h_cnt>=ex)&(h_cnt<=ex+69))e_area =1;
        else e_area=0;end
    0: begin e_area=0;end
    endcase
end

always@(*)begin ////////////////delete w
    case(mode)
    1:begin  
        if (i>2) w_area=0;
        else if ((v_cnt>=wy)&(v_cnt<=wy+69)&(h_cnt>=wx)&(h_cnt<=wx+69))w_area =1;
        else w_area=0;end
    0:begin w_area=0;end
    endcase
end

always@(*)begin  ///////////////////delete  q
    case(mode)
    1:begin    
        if (i>3) q_area=0;
        else if ((v_cnt>=qy)&(v_cnt<=qy+69)&(h_cnt>=qx)&(h_cnt<=qx+69))q_area =1;
        else q_area=0;end
    0: begin q_area=0;end
    endcase
end

////////////////////////////////////////////////mode==0////////////////////////////////////////////////////

always@(*)begin ///////////////delete a
    case(mode)
    1: begin a_area=0;end
    0:begin 
        if (counterA>0) a_area=0; 
        else if ((v_cnt>=ay)&(v_cnt<=ay+69)&(h_cnt>=ax)&(h_cnt<=ax+69))a_area =1;
        else a_area=0;end
    endcase
end

always@(*)begin///////////delete s
    case(mode)
    1: begin s_area=0;end
    0:begin 
        if (counterS>0) s_area=0;
        else if ((v_cnt>=sy)&(v_cnt<=sy+69)&(h_cnt>=sx)&(h_cnt<=sx+69))s_area =1;
        else s_area=0;end
    endcase
end

always@(*)begin///////////////////////delete d
    case(mode)
    1: begin d_area=0;end
    0:begin 
        if (counterD>0) d_area=0;
        else if ((v_cnt>=dy)&(v_cnt<=dy+69)&(h_cnt>=dx)&(h_cnt<=dx+69))d_area =1;
        else d_area=0;end
    endcase
end

always@(*)begin////////////////////////delete f
    case(mode)
    1: begin f_area=0;end
    0:begin 
        if (counterF>0) f_area=0;
        else if ((v_cnt>=fy)&(v_cnt<=fy+69)&(h_cnt>=fx)&(h_cnt<=fx+69))f_area =1;
        else f_area=0;end
    endcase
end

always@(*)begin ///////////////////delete a1
    case(mode)
    1: begin a1_area=0;end
    0:begin 
        if (counterA>1) a1_area=0;
        else if ((v_cnt>=a1y)&(v_cnt<=a1y+69)&(h_cnt>=a1x)&(h_cnt<=a1x+69))a1_area =1;
        else a1_area=0;end
    endcase
end

always@(*)begin /////////////////////delete e0
    case(mode)
    1: begin e0_area=0;end
    0:begin 
        if (counterE>0) e0_area=0;
        else if ((v_cnt>=e0y)&(v_cnt<=e0y+69)&(h_cnt>=e0x)&(h_cnt<=e0x+69))e0_area =1;
        else e0_area=0;end
    endcase
end

always@(*)begin ///////////////delete s1
    case(mode)
    1: begin s1_area=0;end
    0:begin 
        if (counterS>1) s1_area=0;
        else if ((v_cnt>=s1y)&(v_cnt<=s1y+69)&(h_cnt>=s1x)&(h_cnt<=s1x+69))s1_area =1;
        else s1_area=0;end
    endcase
end

always@(*)begin /////////////////////delete q0
    case(mode)
    1: begin q0_area=0;end
    0:begin 
        if (counterQ>0) q0_area=0;
        else if ((v_cnt>=q0y)&(v_cnt<=q0y+69)&(h_cnt>=q0x)&(h_cnt<=q0x+69))q0_area =1;
        else q0_area=0;end
    endcase
end

always@(*)begin ///////////delete f1
    case(mode)
    1: begin f1_area=0;end
    0:begin 
        if (counterF>1) f1_area=0;
        else if ((v_cnt>=f1y)&(v_cnt<=f1y+69)&(h_cnt>=f1x)&(h_cnt<=f1x+69))f1_area =1;
        else f1_area=0;end
    endcase
end

always@(*)begin /////////////////////delete r0
    case(mode)
    1: begin r0_area=0;end
    0:begin 
        if (counterR>0) r0_area=0;
        else if ((v_cnt>=r0y)&(v_cnt<=r0y+69)&(h_cnt>=r0x)&(h_cnt<=r0x+69))r0_area =1;
        else r0_area=0;end
    endcase
end

always@(*)begin  //////////////delete s2
    case(mode)
    1: begin s2_area=0;end
    0:begin 
        if (counterS>2) s2_area=0;
        else if ((v_cnt>=s2y)&(v_cnt<=s2y+69)&(h_cnt>=s2x)&(h_cnt<=s2x+69))s2_area =1;
        else s2_area=0;end
    endcase
end

always@(*)begin  ////////////////delete e1
    case(mode)
    1: begin e1_area=0;end
    0:begin 
        if (counterE>1) e1_area=0;
        else if ((v_cnt>=e1y)&(v_cnt<=e1y+69)&(h_cnt>=e1x)&(h_cnt<=e1x+69))e1_area =1;
        else e1_area=0;end
    endcase
end

always@(*)begin  //////////////////delete a2
    case(mode)
    1: begin a2_area=0;end
    0:begin 
        if (counterA>2) a2_area=0;
        else if ((v_cnt>=a2y)&(v_cnt<=a2y+69)&(h_cnt>=a2x)&(h_cnt<=a2x+69))a2_area =1;
        else a2_area=0;end
    endcase
end

always@(*)begin /////////////////////delete w0
    case(mode)
    1: begin w0_area=0;end
    0:begin 
        if (counterW>0) w0_area=0;
        else if ((v_cnt>=w0y)&(v_cnt<=w0y+69)&(h_cnt>=w0x)&(h_cnt<=w0x+69))w0_area =1;
        else w0_area=0;end
    endcase
end

always@(*)begin  ////////////delete q1
    case(mode)
    1: begin q1_area=0;end
    0:begin 
        if (counterQ>1) q1_area=0;
        else if ((v_cnt>=q1y)&(v_cnt<=q1y+69)&(h_cnt>=q1x)&(h_cnt<=q1x+69))q1_area =1;
        else q1_area=0;end
    endcase
end

always@(*)begin  ///////////delete e2
    case(mode)
    1: begin e2_area=0;end
    0:begin 
        if (counterE>2) e2_area=0;
        else if ((v_cnt>=e2y)&(v_cnt<=e2y+69)&(h_cnt>=e2x)&(h_cnt<=e2x+69))e2_area =1;
        else e2_area=0;end
    endcase
end
///////////////////////////////background of the game////////////////////////////////////
//vertical line
assign k=((h_cnt>=159)&&(h_cnt<=163)&&(v_cnt>=0)&&(v_cnt<=157)&&(mode==0))?1'b1:1'b0;
assign l=((h_cnt>=239)&&(h_cnt<=243)&&(v_cnt>=0)&&(v_cnt<=157)&&(mode==0))?1'b1:1'b0;
assign m=((h_cnt>=319)&&(h_cnt<=323)&&(v_cnt>=0)&&(v_cnt<=157)&&(mode==0))?1'b1:1'b0;
assign a=((h_cnt>=159)&&(h_cnt<=163)&&(v_cnt>=158)&&(v_cnt<=480))?1'b1:1'b0;
assign b=((h_cnt>=239)&&(h_cnt<=243)&&(v_cnt>=158)&&(v_cnt<=480))?1'b1:1'b0;
assign c=((h_cnt>=319)&&(h_cnt<=323)&&(v_cnt>=158)&&(v_cnt<=480))?1'b1:1'b0;
assign d=((h_cnt>=399)&&(h_cnt<=403)&&(v_cnt>=158)&&(v_cnt<=480))?1'b1:1'b0;
assign e=((h_cnt>=479)&&(h_cnt<=483)&&(v_cnt>=158)&&(v_cnt<=480))?1'b1:1'b0;
//horizontal line
assign n=((v_cnt>=0)&&(v_cnt<=5)&&(h_cnt>=159)&&(h_cnt<=323)&&(mode==0))?1'b1:1'b0;
assign o=((v_cnt>=78)&&(v_cnt<=82)&&(h_cnt>=159)&&(h_cnt<=323)&&(mode==0))?1'b1:1'b0;
assign f=((v_cnt>=158)&&(v_cnt<=163)&&(h_cnt>=159)&&(h_cnt<=483))?1'b1:1'b0;
assign g=((v_cnt>=238)&&(v_cnt<=242)&&(h_cnt>=159)&&(h_cnt<=483))?1'b1:1'b0;
assign h=((v_cnt>=318)&&(v_cnt<=322)&&(h_cnt>=159)&&(h_cnt<=483))?1'b1:1'b0;
assign ii=((v_cnt>=398)&&(v_cnt<=402)&&(h_cnt>=159)&&(h_cnt<=483))?1'b1:1'b0;
assign jj=((v_cnt>=476)&&(v_cnt<=480)&&(h_cnt>=159)&&(h_cnt<=483))?1'b1:1'b0;
// 最後增加的4個W
assign aw1=((v_cnt>=15)&&(v_cnt<=67)&&(h_cnt>=173)&&(h_cnt<=184)&&(mode==0)&&(20>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign aw2=((v_cnt>=32)&&(v_cnt<=67)&&(h_cnt>=195)&&(h_cnt<=206)&&(mode==0)&&(20>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign aw3=((v_cnt>=15)&&(v_cnt<=67)&&(h_cnt>=217)&&(h_cnt<=228)&&(mode==0)&&(20>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign aw4=((v_cnt>=56)&&(v_cnt<=67)&&(h_cnt>=173)&&(h_cnt<=228)&&(mode==0)&&(20>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign bw1=((v_cnt>=15)&&(v_cnt<=67)&&(h_cnt>=253)&&(h_cnt<=264)&&(mode==0)&&(19>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign bw2=((v_cnt>=32)&&(v_cnt<=67)&&(h_cnt>=275)&&(h_cnt<=286)&&(mode==0)&&(19>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign bw3=((v_cnt>=15)&&(v_cnt<=67)&&(h_cnt>=297)&&(h_cnt<=308)&&(mode==0)&&(19>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign bw4=((v_cnt>=56)&&(v_cnt<=67)&&(h_cnt>=253)&&(h_cnt<=308)&&(mode==0)&&(19>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign cw1=((v_cnt>=92)&&(v_cnt<=147)&&(h_cnt>=173)&&(h_cnt<=184)&&(mode==0)&&(18>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign cw2=((v_cnt>=112)&&(v_cnt<=147)&&(h_cnt>=195)&&(h_cnt<=206)&&(mode==0)&&(18>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign cw3=((v_cnt>=92)&&(v_cnt<=147)&&(h_cnt>=217)&&(h_cnt<=228)&&(mode==0)&&(18>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign cw4=((v_cnt>=136)&&(v_cnt<=147)&&(h_cnt>=173)&&(h_cnt<=228)&&(mode==0)&&(18>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign dw1=((v_cnt>=92)&&(v_cnt<=147)&&(h_cnt>=253)&&(h_cnt<=264)&&(mode==0)&&(17>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign dw2=((v_cnt>=112)&&(v_cnt<=147)&&(h_cnt>=275)&&(h_cnt<=286)&&(mode==0)&&(17>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign dw3=((v_cnt>=92)&&(v_cnt<=147)&&(h_cnt>=297)&&(h_cnt<=308)&&(mode==0)&&(17>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign dw4=((v_cnt>=136)&&(v_cnt<=147)&&(h_cnt>=253)&&(h_cnt<=308)&&(mode==0)&&(17>i&&(counter_led>=8||i>=16)))?1'b1:1'b0;
assign ew1=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=173)&&(h_cnt<=184)&&(mode==0)&&(counter_led>=8&&16>i&&i>=12))?1'b1:1'b0;
assign ew2=((v_cnt>=192)&&(v_cnt<=227)&&(h_cnt>=195)&&(h_cnt<=206)&&(mode==0)&&(counter_led>=8&&16>i&&i>=12))?1'b1:1'b0;
assign ew3=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=217)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&16>i&&i>=12))?1'b1:1'b0;
assign ew4=((v_cnt>=216)&&(v_cnt<=227)&&(h_cnt>=173)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&16>i&&i>=12))?1'b1:1'b0;
assign fw1=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=253)&&(h_cnt<=264)&&(mode==0)&&(counter_led>=8&&15>i&&i>=11))?1'b1:1'b0;
assign fw2=((v_cnt>=192)&&(v_cnt<=227)&&(h_cnt>=275)&&(h_cnt<=286)&&(mode==0)&&(counter_led>=8&&15>i&&i>=11))?1'b1:1'b0;
assign fw3=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=297)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&15>i&&i>=11))?1'b1:1'b0;
assign fw4=((v_cnt>=216)&&(v_cnt<=227)&&(h_cnt>=253)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&15>i&&i>=11))?1'b1:1'b0;
assign gw1=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=333)&&(h_cnt<=344)&&(mode==0)&&(counter_led>=8&&14>i&&i>=10))?1'b1:1'b0;
assign gw2=((v_cnt>=192)&&(v_cnt<=227)&&(h_cnt>=355)&&(h_cnt<=366)&&(mode==0)&&(counter_led>=8&&14>i&&i>=10))?1'b1:1'b0;
assign gw3=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=377)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&14>i&&i>=10))?1'b1:1'b0;
assign gw4=((v_cnt>=216)&&(v_cnt<=227)&&(h_cnt>=333)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&14>i&&i>=10))?1'b1:1'b0;
assign hw1=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=413)&&(h_cnt<=424)&&(mode==0)&&(counter_led>=8&&13>i&&i>=9))?1'b1:1'b0;
assign hw2=((v_cnt>=192)&&(v_cnt<=227)&&(h_cnt>=435)&&(h_cnt<=446)&&(mode==0)&&(counter_led>=8&&13>i&&i>=9))?1'b1:1'b0;
assign hw3=((v_cnt>=172)&&(v_cnt<=227)&&(h_cnt>=457)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&13>i&&i>=9))?1'b1:1'b0;
assign hw4=((v_cnt>=216)&&(v_cnt<=227)&&(h_cnt>=413)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&13>i&&i>=9))?1'b1:1'b0;
assign iw1=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=173)&&(h_cnt<=184)&&(mode==0)&&(counter_led>=8&&12>i&&i>=8))?1'b1:1'b0;
assign iw2=((v_cnt>=272)&&(v_cnt<=307)&&(h_cnt>=195)&&(h_cnt<=206)&&(mode==0)&&(counter_led>=8&&12>i&&i>=8))?1'b1:1'b0;
assign iw3=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=217)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&12>i&&i>=8))?1'b1:1'b0;
assign iw4=((v_cnt>=296)&&(v_cnt<=307)&&(h_cnt>=173)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&12>i&&i>=8))?1'b1:1'b0;
assign jw1=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=253)&&(h_cnt<=264)&&(mode==0)&&(counter_led>=8&&11>i&&i>=7))?1'b1:1'b0;
assign jw2=((v_cnt>=272)&&(v_cnt<=307)&&(h_cnt>=275)&&(h_cnt<=286)&&(mode==0)&&(counter_led>=8&&11>i&&i>=7))?1'b1:1'b0;
assign jw3=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=297)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&11>i&&i>=7))?1'b1:1'b0;
assign jw4=((v_cnt>=296)&&(v_cnt<=307)&&(h_cnt>=253)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&11>i&&i>=7))?1'b1:1'b0;
assign kw1=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=333)&&(h_cnt<=344)&&(mode==0)&&(counter_led>=8&&10>i&&i>=6))?1'b1:1'b0;
assign kw2=((v_cnt>=272)&&(v_cnt<=307)&&(h_cnt>=355)&&(h_cnt<=366)&&(mode==0)&&(counter_led>=8&&10>i&&i>=6))?1'b1:1'b0;
assign kw3=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=377)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&10>i&&i>=6))?1'b1:1'b0;
assign kw4=((v_cnt>=296)&&(v_cnt<=307)&&(h_cnt>=333)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&10>i&&i>=6))?1'b1:1'b0;
assign lw1=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=413)&&(h_cnt<=424)&&(mode==0)&&(counter_led>=8&&9>i&&i>=5))?1'b1:1'b0;
assign lw2=((v_cnt>=272)&&(v_cnt<=307)&&(h_cnt>=435)&&(h_cnt<=446)&&(mode==0)&&(counter_led>=8&&9>i&&i>=5))?1'b1:1'b0;
assign lw3=((v_cnt>=252)&&(v_cnt<=307)&&(h_cnt>=457)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&9>i&&i>=5))?1'b1:1'b0;
assign lw4=((v_cnt>=296)&&(v_cnt<=307)&&(h_cnt>=413)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&9>i&&i>=5))?1'b1:1'b0;
assign mw1=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=173)&&(h_cnt<=184)&&(mode==0)&&(counter_led>=8&&8>i&&i>=4))?1'b1:1'b0;
assign mw2=((v_cnt>=352)&&(v_cnt<=387)&&(h_cnt>=195)&&(h_cnt<=206)&&(mode==0)&&(counter_led>=8&&8>i&&i>=4))?1'b1:1'b0;
assign mw3=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=217)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&8>i&&i>=4))?1'b1:1'b0;
assign mw4=((v_cnt>=376)&&(v_cnt<=387)&&(h_cnt>=173)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&8>i&&i>=4))?1'b1:1'b0;
assign nw1=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=253)&&(h_cnt<=264)&&(mode==0)&&(counter_led>=8&&7>i&&i>=3))?1'b1:1'b0;
assign nw2=((v_cnt>=352)&&(v_cnt<=387)&&(h_cnt>=275)&&(h_cnt<=286)&&(mode==0)&&(counter_led>=8&&7>i&&i>=3))?1'b1:1'b0;
assign nw3=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=297)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&7>i&&i>=3))?1'b1:1'b0;
assign nw4=((v_cnt>=376)&&(v_cnt<=387)&&(h_cnt>=253)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&7>i&&i>=3))?1'b1:1'b0;
assign ow1=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=333)&&(h_cnt<=344)&&(mode==0)&&(counter_led>=8&&6>i&&i>=2))?1'b1:1'b0;
assign ow2=((v_cnt>=352)&&(v_cnt<=387)&&(h_cnt>=355)&&(h_cnt<=366)&&(mode==0)&&(counter_led>=8&&6>i&&i>=2))?1'b1:1'b0;
assign ow3=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=377)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&6>i&&i>=2))?1'b1:1'b0;
assign ow4=((v_cnt>=376)&&(v_cnt<=387)&&(h_cnt>=333)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&6>i&&i>=2))?1'b1:1'b0;
assign pw1=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=413)&&(h_cnt<=424)&&(mode==0)&&(counter_led>=8&&5>i&&i>=1))?1'b1:1'b0;
assign pw2=((v_cnt>=352)&&(v_cnt<=387)&&(h_cnt>=435)&&(h_cnt<=446)&&(mode==0)&&(counter_led>=8&&5>i&&i>=1))?1'b1:1'b0;
assign pw3=((v_cnt>=332)&&(v_cnt<=387)&&(h_cnt>=457)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&5>i&&i>=1))?1'b1:1'b0;
assign pw4=((v_cnt>=376)&&(v_cnt<=387)&&(h_cnt>=413)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&5>i&&i>=1))?1'b1:1'b0;
assign qw1=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=173)&&(h_cnt<=184)&&(mode==0)&&(counter_led>=8&&4>i&&i>=0))?1'b1:1'b0;
assign qw2=((v_cnt>=430)&&(v_cnt<=465)&&(h_cnt>=195)&&(h_cnt<=206)&&(mode==0)&&(counter_led>=8&&4>i&&i>=0))?1'b1:1'b0;
assign qw3=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=217)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&4>i&&i>=0))?1'b1:1'b0;
assign qw4=((v_cnt>=454)&&(v_cnt<=465)&&(h_cnt>=173)&&(h_cnt<=228)&&(mode==0)&&(counter_led>=8&&4>i&&i>=0))?1'b1:1'b0;
assign rw1=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=253)&&(h_cnt<=264)&&(mode==0)&&(counter_led>=8&&3>i))?1'b1:1'b0;
assign rw2=((v_cnt>=430)&&(v_cnt<=465)&&(h_cnt>=275)&&(h_cnt<=286)&&(mode==0)&&(counter_led>=8&&3>i))?1'b1:1'b0;
assign rw3=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=297)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&3>i))?1'b1:1'b0;
assign rw4=((v_cnt>=454)&&(v_cnt<=465)&&(h_cnt>=253)&&(h_cnt<=308)&&(mode==0)&&(counter_led>=8&&3>i))?1'b1:1'b0;
assign sw1=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=333)&&(h_cnt<=344)&&(mode==0)&&(counter_led>=8&&2>i))?1'b1:1'b0;
assign sw2=((v_cnt>=430)&&(v_cnt<=465)&&(h_cnt>=355)&&(h_cnt<=366)&&(mode==0)&&(counter_led>=8&&2>i))?1'b1:1'b0;
assign sw3=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=377)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&2>i))?1'b1:1'b0;
assign sw4=((v_cnt>=454)&&(v_cnt<=465)&&(h_cnt>=333)&&(h_cnt<=388)&&(mode==0)&&(counter_led>=8&&2>i))?1'b1:1'b0;
assign tw1=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=413)&&(h_cnt<=424)&&(mode==0)&&(counter_led>=8&&i==0))?1'b1:1'b0;
assign tw2=((v_cnt>=430)&&(v_cnt<=465)&&(h_cnt>=435)&&(h_cnt<=446)&&(mode==0)&&(counter_led>=8&&i==0))?1'b1:1'b0;
assign tw3=((v_cnt>=412)&&(v_cnt<=465)&&(h_cnt>=457)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&i==0))?1'b1:1'b0;
assign tw4=((v_cnt>=454)&&(v_cnt<=465)&&(h_cnt>=413)&&(h_cnt<=468)&&(mode==0)&&(counter_led>=8&&i==0))?1'b1:1'b0;
////// 關卡顯示
assign level1=((v_cnt>=435)&&(v_cnt<=442)&&(h_cnt>=57)&&(h_cnt<=112)&&(mode==1))?1'b1:1'b0;
assign level2_1=((v_cnt>=418)&&(v_cnt<=425)&&(h_cnt>=79)&&(h_cnt<=110)&&(mode==0))?1'b1:1'b0;
assign level2_2=((v_cnt>=445)&&(v_cnt<=452)&&(h_cnt>=67)&&(h_cnt<=122)&&(mode==0))?1'b1:1'b0;
//遊戲畫面顯示
always @(posedge pclk or negedge rst)begin 
      if (!rst) begin
         rom_addr_e<=14'd0;rom_addr_e1<=14'd0;rom_addr_e2<=14'd0;rom_addr_q<=14'd0;rom_addr_q1<=14'd0;
         rom_addr_r<=14'd0;rom_addr_w<=14'd0;rom_addr_a<=14'd0;rom_addr_q0<=14'd0;rom_addr_a1<=14'd0;
         rom_addr_a2<=14'd0;rom_addr_s<=14'd0;rom_addr_w0<=14'd0;rom_addr_s1<=14'd0;rom_addr_s2<=14'd0;
         rom_addr_d<=14'd0;   rom_addr_e0<=14'd0;rom_addr_f<=14'd0;rom_addr_r0<=14'd0;rom_addr_f1<=14'd0;
         vga_data <= 12'b0000_0000_0011;end
      else begin
         if (valid == 1'b1)begin
            case (mode)
            1:begin
            if (r_area==1)begin
               rom_addr_e<=rom_addr_e;rom_addr_q<=rom_addr_q;rom_addr_r<=rom_addr_r + 14'd1;rom_addr_w<=rom_addr_w;
               vga_data <= rom_dout_r;end
            else if (q_area==1)begin
               rom_addr_e<=rom_addr_e;rom_addr_q<=rom_addr_q + 14'd1;rom_addr_r<=rom_addr_r;rom_addr_w<=rom_addr_w;
               vga_data <= rom_dout_q;end
            else if (w_area==1)begin
               rom_addr_e<=rom_addr_e;rom_addr_q<=rom_addr_q;rom_addr_r<=rom_addr_r;rom_addr_w<=rom_addr_w + 14'd1;
               vga_data <= rom_dout_w;end
            else if (e_area ==1)begin
               rom_addr_e<=rom_addr_e + 14'd1;rom_addr_q<=rom_addr_q;rom_addr_r<=rom_addr_r;rom_addr_w<=rom_addr_w;
               vga_data <= rom_dout_e;end
            else if ((a||b||c||d||e||f||g||h||ii||jj||k||l||m||n||o)==1'b1)begin
               vga_data <= 12'h0;end //遊戲格線
            else if(level1==1)begin
                vga_data<=12'b0000_0000_0011; end //顯示關卡一
            else begin
               rom_addr_e <= rom_addr_e;rom_addr_q <= rom_addr_q;rom_addr_r <= rom_addr_r;rom_addr_w <= rom_addr_w;
               vga_data <= 12'hfff;end
            end// mode==1
            0:begin
            if (e0_area ==1)begin
               rom_addr_e0<=rom_addr_e0 + 14'd1;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_e0;end
            else if (q0_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0+ 14'd1;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_q0;end
            else if (r0_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0+ 14'd1;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_r0;end
            else if (w0_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0 ;rom_addr_w0<=rom_addr_w0+ 14'd1;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_w0;end
            else if (e1_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1+ 14'd1;rom_addr_q1<=rom_addr_q1;rom_addr_r0<=rom_addr_r0 ;
               rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;
               rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;
               rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;rom_addr_e2<=rom_addr_e2;rom_addr_q0<=rom_addr_q0;
               vga_data <= rom_dout_e1;end
            else if (e2_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1 ;rom_addr_e2<=rom_addr_e2+ 14'd1;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0 ;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_e2;end
            else if (q1_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1 ;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1+ 14'd1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0 ;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_q1;end
            else if (a_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1 ;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0 ;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a+ 14'd1;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_a;end
            else if (a1_area==1)begin
              rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1 ;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0 ;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1+ 14'd1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_a1;end
            else if (a2_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1 ;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0 ;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2+ 14'd1;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_a2;end 
            else if (s_area==1)begin
               rom_addr_e0<=rom_addr_e0 ;rom_addr_e1<=rom_addr_e1 ;rom_addr_e2<=rom_addr_e2;rom_addr_q1<=rom_addr_q1;
               rom_addr_q0<=rom_addr_q0;rom_addr_r0<=rom_addr_r0 ;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s+ 14'd1;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_s;end
            else if (s1_area==1)begin
               rom_addr_e0<=rom_addr_e0;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q0<=rom_addr_q0;
               rom_addr_q1<=rom_addr_q1;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1 + 14'd1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_s1;end
            else if (s2_area==1)begin
               rom_addr_e0<=rom_addr_e0;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q0<=rom_addr_q0;
               rom_addr_q1<=rom_addr_q1;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2 + 14'd1;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_s2;end 
            else if (d_area==1)begin
               rom_addr_e0<=rom_addr_e0;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q0<=rom_addr_q0;
               rom_addr_q1<=rom_addr_q1;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d + 14'd1;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_d;end
            else if (f_area==1)begin
               rom_addr_e0<=rom_addr_e0;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q0<=rom_addr_q0;
               rom_addr_q1<=rom_addr_q1;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f + 14'd1;rom_addr_f1<=rom_addr_f1;
               vga_data <= rom_dout_f;end
            else if (f1_area==1)begin
               rom_addr_e0<=rom_addr_e0;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q0<=rom_addr_q0;
               rom_addr_q1<=rom_addr_q1;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f;rom_addr_f1<=rom_addr_f1 + 14'd1;
               vga_data <= rom_dout_f1;end
            else if ((a||b||c||d||e||f||g||h||ii||jj||k||l||m||n||o)==1'b1)begin
               vga_data <= 12'h0;end //顯示遊戲格線
            else if ((aw1||aw2||aw3||aw4||bw1||bw2||bw3||bw4||cw1||cw2||cw3||cw4||dw1||dw2||dw3||dw4||ew1||ew2||ew3||ew4||fw1||fw2||fw3||fw4||gw1||gw2||gw3||gw4||hw1||hw2||hw3||hw4||iw1||iw2||iw3||iw4||jw1||jw2||jw3||jw4||kw1||kw2||kw3||kw4||lw1||lw2||lw3||lw4||mw1||mw2||mw3||mw4||nw1||nw2||nw3||nw4||ow1||ow2||ow3||ow4||pw1||pw2||pw3||pw4||qw1||qw2||qw3||qw4||rw1||rw2||rw3||rw4||sw1||sw2||sw3||sw4||tw1||tw2||tw3||tw4)==1'b1)begin
               vga_data<= 12'b0000_0000_1111;end //最後加的四個字母
            else if ((level2_1||level2_2)==1)begin
                vga_data<= 12'b0000_0000_0011;end//顯示關卡二
            else begin
               vga_data <= 12'hfff;end
            end //mode==0
            endcase
         end  // vaild==1
         else begin // vaild==0
            vga_data <= 12'h000;
            if (v_cnt == 0)begin
                rom_addr_e<=14'd0;rom_addr_e1<=14'd0;rom_addr_e2<=14'd0;rom_addr_q<=14'd0;
                rom_addr_q1<=14'd0;rom_addr_r<=14'd0;rom_addr_w<=14'd0;rom_addr_a<=14'd0;
                rom_addr_q0<=14'd0;rom_addr_a1<=14'd0;rom_addr_a2<=14'd0;rom_addr_s<=14'd0;
                rom_addr_w0<=14'd0;rom_addr_s1<=14'd0;rom_addr_s2<=14'd0;rom_addr_d<=14'd0;
                rom_addr_e0<=14'd0;rom_addr_f<=14'd0;rom_addr_r0<=14'd0;rom_addr_f1<=14'd0;end
            else begin
               rom_addr_e <= rom_addr_e;rom_addr_q <= rom_addr_q;rom_addr_r <= rom_addr_r;rom_addr_w <= rom_addr_w;
               rom_addr_e0<=rom_addr_e0;rom_addr_e1<=rom_addr_e1;rom_addr_e2<=rom_addr_e2;rom_addr_q0<=rom_addr_q0;
               rom_addr_q1<=rom_addr_q1;rom_addr_r0<=rom_addr_r0;rom_addr_w0<=rom_addr_w0;rom_addr_a<=rom_addr_a;
               rom_addr_a1<=rom_addr_a1;rom_addr_a2<=rom_addr_a2;rom_addr_s<=rom_addr_s;rom_addr_s1<=rom_addr_s1;
               rom_addr_s2<=rom_addr_s2;rom_addr_d<=rom_addr_d;rom_addr_f<=rom_addr_f ;rom_addr_f1<=rom_addr_f1;end
         end/// vaild==0
      end// reset
   end
   
assign {vga_r,vga_g,vga_b} = vga_data;
//////////////////////////////////////////////////////mode==1///////////////////////////////////////////////////////////////////////
always@(posedge clk or negedge rst)begin ///////////////position of r
  if(!rst)begin 
    rx<=10'd166;ry<=10'd167;end
  else if (mode) begin
    rx<=rx;ry<=ry;end
end

always@(posedge clk or negedge rst)begin /////////////////position of e
    if(!rst)begin 
        ex<=10'd246;ey<=10'd167;end
    else if (mode)  begin
        ex<=ex;ey<=ey;end
end

always@(posedge clk or negedge rst)begin  ///////////////////////////////position of q
   if(!rst)begin
      qx<=10'd406; qy<=10'd167;end
   else if (mode)begin
        qx<=qx; qy<=qy;end
end

always@(posedge clk or negedge rst)begin  //////////////////////////position of w
     if(!rst)begin
       wx<=10'd326;wy<=10'd167;end 
    else if (mode) begin 
        wx<=wx; wy<=wy;end 
end
//////////////////////////////////////////////////////mode==0 /////////////////////////////////////////////////////////////////
///////////////// enhance the condition of deleting the letter (消完順序在前面的字母才能往後消)
always@(posedge clk)begin
delete<=4'd0;
if (counterD==0&&counterE==0&&counterF==0&&counterQ==0&&counterR==0&&counterS==0&&counterW==0) delete<=da;
else if (counterA==3&&counterD==1&&counterE==0&&counterF==0&&counterQ==0&&counterR==0&&counterS==0&&counterW==0) delete<=dd;
else if (counterA==3&&counterD==1&&counterF==0&&counterQ==0&&counterR==0&&counterS==0&&counterW==0) delete<=de;
else if (counterQ==0&&counterR==0&&counterS==0&&counterW==0) delete<=df;
else if (counterR==0&&counterS==0&&counterW==0) delete<=dq;
else if (counterS==0&&counterW==0) delete<=dr;
else if (counterW==0) delete<=ds;
end

always@(posedge clk or negedge rst)begin  /////////////position of a
    if (!rst)begin
            ax<=10'd166;
            ay<=10'd7;end
    else begin 
        ax<=ax; ay<=ay;end
end

always@(posedge clk or negedge rst)begin    //////////////////position of s
    if (!rst)begin
            sx<=10'd246;
            sy<=10'd7;end
        else if (counterA==1&&delete==da)begin sx<=10'd166;sy<=10'd7;end
        else begin sx<=sx; sy<=sy;end
end

always@(posedge clk or negedge rst)begin  ///////////////position of d
    if (!rst)begin
            dx<=10'd166;
            dy<=10'd87;end
    else if (counterA==1&&delete==da)begin dx<=10'd246; dy<=10'd7;end
    else begin 
        dx<=dx; dy<=dy;end
end

always@(posedge clk or negedge rst)begin  //////////////position of f
    if (!rst)begin
            fx<=10'd246;
            fy<=10'd87;end 
    else if (counterD==1&&delete==dd)begin fx<=10'd246; fy<=10'd7;end
    else if (counterA==1&&delete==da)begin fx<=10'd166; fy<=10'd87;end
    else begin 
        fx<=fx; fy<=fy;end
end

always@(posedge clk or negedge rst)begin   //////////position of a1
    if (!rst)begin
            a1x<=10'd166;
            a1y<=10'd167;end
    else if (counterA==1&&delete==da)begin a1x<=10'd246; a1y<=10'd87;end
    else begin 
        a1x<=a1x; a1y<=a1y;end
end

always@(posedge clk or negedge rst)begin /////////////////position of e0
    if(!rst)begin
            e0x<=10'd246;
            e0y<=10'd167;end
    else if (counterD==1&&delete==dd)begin e0x<=10'd166; e0y<=10'd87;end
    else if (counterS==1&&delete==ds)begin e0x<=10'd166; e0y<=10'd87;end
    else if (counterA==1&&delete==da)begin e0x<=10'd166; e0y<=10'd167;end
    else if (counterA==2&&delete==da)begin e0x<=10'd246; e0y<=10'd87;end
    else begin
        e0x<=e0x;e0y<=e0y;end
end

always@(posedge clk or negedge rst)begin  /////////////position of s1
    if (!rst)begin
            s1x<=10'd326;
            s1y<=10'd167;end  
    else if (counterS==1&&delete==ds)begin s1x<=10'd166; s1y<=10'd7;end
    else if (counterF==1&&delete==df)begin s1x<=10'd246; s1y<=10'd7;end    
    else if (counterE==1&&delete==de)begin s1x<=10'd166; s1y<=10'd87;end
    else if (counterD==1&&delete==dd)begin s1x<=10'd246; s1y<=10'd87;end
    else if (counterA==1&&delete==da)begin s1x<=10'd246; s1y<=10'd167;end
    else if (counterA==2&&delete==da)begin s1x<=10'd166; s1y<=10'd167;end
    else begin 
        s1x<=s1x; s1y<=s1y;end
end

always@(posedge clk or negedge rst)begin  ///////////////////////////////position of q0
    if(!rst)begin
            q0x<=10'd406;
            q0y<=10'd167;end
    else if (counterF==1&&delete==df)begin q0x<=10'd166; q0y<=10'd87;end           
    else if (counterE==1&&delete==de)begin q0x<=10'd246; q0y<=10'd87;end
    else if (counterD==1&&delete==dd)begin q0x<=10'd166; q0y<=10'd167;end   
    else if (counterA==1&&delete==da)begin q0x<=10'd326; q0y<=10'd167;end
    else if (counterA==2&&delete==da)begin q0x<=10'd246; q0y<=10'd167;end
    else begin
        q0x<=q0x;q0y<=q0y;end
end

always@(posedge clk or negedge rst)begin    ///////position of f1
    if (!rst)begin
            f1x<=10'd166;
            f1y<=10'd247;end
    else if (counterF==1&&delete==df)begin f1x<=10'd246; f1y<=10'd87;end       
    else if (counterE==1&&delete==de)begin f1x<=10'd166; f1y<=10'd167;end
    else if (counterD==1&&delete==dd)begin f1x<=10'd246; f1y<=10'd167;end    
    else if (counterA==1&&delete==da)begin f1x<=10'd406; f1y<=10'd167;end
    else if (counterA==2&&delete==da)begin f1x<=10'd326; f1y<=10'd167;end
    else begin 
        f1x<=f1x; f1y<=f1y;end
end

always@(posedge clk or negedge rst)begin ///////////////position of r0
    if(!rst)begin
            r0x<=10'd246;
            r0y<=10'd247;end
    else if (counterQ==1&&delete==dq)begin r0x<=10'd166; r0y<=10'd87;end
    else if (counterF==2&&delete==df)begin r0x<=10'd246; r0y<=10'd87;end    
    else if (counterF==1&&delete==df)begin r0x<=10'd166; r0y<=10'd167;end       
    else if (counterE==1&&delete==de)begin r0x<=10'd246; r0y<=10'd167;end     
    else if (counterD==1&&delete==dd)begin r0x<=10'd326; r0y<=10'd167;end          
    else if (counterA==1&&delete==da)begin r0x<=10'd166; r0y<=10'd247;end
    else if (counterA==2&&delete==da)begin r0x<=10'd406; r0y<=10'd167;end
    else begin
        r0x<=r0x;r0y<=r0y;end
end

always@(posedge clk or negedge rst)begin  /////////////position of s2
    if (!rst)begin
            s2x<=10'd326;
            s2y<=10'd247;end
    else if (counterS==2&&delete==ds)begin s2x<=10'd166; s2y<=10'd7;end
    else if (counterS==1&&delete==ds)begin s2x<=10'd246; s2y<=10'd7;end 
    else if (counterR==1&&delete==dr)begin s2x<=10'd166; s2y<=10'd87;end
    else if (counterQ==1&&delete==dq)begin s2x<=10'd246; s2y<=10'd87;end    
    else if (counterF==2&&delete==df)begin s2x<=10'd166; s2y<=10'd167;end    
    else if (counterF==1&&delete==df)begin s2x<=10'd246; s2y<=10'd167;end    
    else if (counterE==1&&delete==de)begin s2x<=10'd326; s2y<=10'd167;end
    else if (counterD==1&&delete==dd)begin s2x<=10'd406; s2y<=10'd167;end    
    else if (counterA==1&&delete==da)begin s2x<=10'd246; s2y<=10'd247;end
    else if (counterA==2&&delete==da)begin s2x<=10'd166; s2y<=10'd247;end
    else begin 
        s2x<=s2x; s2y<=s2y;end
end

always@(posedge clk or negedge rst)begin    ///////////position of e1
    if (!rst)begin
            e1x<=10'd406;
            e1y<=10'd247;
    end//rst
    else if (counterE==1&&delete==de)begin e1x<=10'd406; e1y<=10'd167;end    
    else if (counterD==1&&delete==dd)begin e1x<=10'd166; e1y<=10'd247;end        
    else if (counterA==1&&delete==da)begin e1x<=10'd326; e1y<=10'd247;end
    else if (counterA==2&&delete==da)begin e1x<=10'd246; e1y<=10'd247;end
    else begin 
        e1x<=e1x; e1y<=e1y;end
end

always@(posedge clk or negedge rst)begin  ///////position of a2
    if (!rst)begin
            a2x<=10'd166;
            a2y<=10'd327;end
    else if (counterA==1&&delete==da)begin a2x<=10'd406; a2y<=10'd247;end
    else if (counterA==2&&delete==da)begin a2x<=10'd326; a2y<=10'd247;end
    else begin 
        a2x<=a2x; a2y<=a2y;end
end

always@(posedge clk or negedge rst)begin  //////////////////////////position of w0
    if (!rst)begin   
            w0x<=10'd246;
            w0y<=10'd327;
    end// if rst
    else if (counterS==3&&delete==ds)begin w0x<=10'd166; w0y<=10'd7;end
    else if (counterS==2&&delete==ds)begin w0x<=10'd246; w0y<=10'd7;end
    else if (counterS==1&&delete==ds)begin w0x<=10'd166; w0y<=10'd87;end    
    else if (counterR==1&&delete==dr)begin w0x<=10'd246; w0y<=10'd87;end   
    else if (counterQ==1&&delete==dq)begin w0x<=10'd166; w0y<=10'd167;end    
    else if (counterF==2&&delete==df)begin w0x<=10'd246; w0y<=10'd167;end       
    else if (counterF==1&&delete==df)begin w0x<=10'd326; w0y<=10'd167;end     
    else if (counterE==2&&delete==de)begin w0x<=10'd406; w0y<=10'd167;end          
    else if (counterE==1&&delete==de)begin w0x<=10'd166; w0y<=10'd247;end    
    else if (counterD==1&&delete==dd)begin w0x<=10'd246; w0y<=10'd247;end
    else if (counterA==3&&delete==da)begin w0x<=10'd326; w0y<=10'd247;end    
    else if (counterA==1&&delete==da)begin w0x<=10'd166; w0y<=10'd327;end
    else if (counterA==2&&delete==da)begin w0x<=10'd406; w0y<=10'd247;end
    else begin
        w0x<=w0x;w0y<=w0y;end
end

always@(posedge clk or negedge rst)begin   ///////////////position of q1
    if (!rst)begin
            q1x<=10'd326;
            q1y<=10'd327;end
   else if (cs==run&&mode==0)begin  
    if (counterQ==1&&delete==dq)begin q1x<=10'd246; q1y<=10'd167;end    
    else if (counterF==2&&delete==df)begin q1x<=10'd326; q1y<=10'd167;end       
    else if (counterF==1&&delete==df)begin q1x<=10'd406; q1y<=10'd167;end     
    else if (counterE==2&&delete==de)begin q1x<=10'd166; q1y<=10'd247;end          
    else if (counterE==1&&delete==de)begin q1x<=10'd246; q1y<=10'd247;end    
    else if (counterD==1&&delete==dd)begin q1x<=10'd326; q1y<=10'd247;end
    else if (counterA==3&&delete==da)begin q1x<=10'd406; q1y<=10'd247;end    
    else if (counterA==1&&delete==da)begin q1x<=10'd246; q1y<=10'd327;end
    else if (counterA==2&&delete==da)begin q1x<=10'd166; q1y<=10'd327;end
    else begin 
        q1x<=q1x; q1y<=q1y;end end
  else begin 
        q1x<=q1x; q1y<=q1y;end 
end

always@(posedge clk or negedge rst)begin   ////////position of e2
    if (!rst)begin
            e2x<=10'd406;
            e2y<=10'd327;end
   else if (cs==run&&mode==0)begin     
    if (counterE==2&&delete==de)begin e2x<=10'd246; e2y<=10'd247;end          
    else if (counterE==1&&delete==de)begin e2x<=10'd326; e2y<=10'd247;end    
    else if (counterD==1&&delete==dd)begin e2x<=10'd406; e2y<=10'd247;end
    else if (counterA==3&&delete==da)begin e2x<=10'd166; e2y<=10'd327;end    
    else if (counterA==1&&delete==da)begin e2x<=10'd326; e2y<=10'd327;end
    else if (counterA==2&&delete==da)begin e2x<=10'd246; e2y<=10'd327;end
    else begin 
        e2x<=e2x; e2y<=e2y;end end
  else begin 
        e2x<=e2x; e2y<=e2y;end 
end


//////////////////////////////////////////////遊戲規則、計分.../////////////////////////////////////////////////////////////////////////////by 曾郁瑄


always@(posedge clk , negedge rst) 
begin
if(!rst)
    counter26 <= 0;
else
    counter26 <= counter26 + 1'b1;
end

always@(posedge clk , negedge rst) /////////除頻clk 
begin
if(!rst)begin 
    clk_seg <= 0;
    clk_segr <= 0; end
else
    clk_seg <= counter26[18];////////////左seg閃
    clk_segr <= counter26[17];////////右ssg閃
    clk_led <= counter26[26];/////1Hz led一秒熄一顆
end

always@(posedge clk_seg , negedge rst)///////counter of en_ssl
begin
if(!rst)
    counter_ssl <= 0;
else
    counter_ssl <= counter_ssl + 1;
end
always@(*)///////en_ssl
begin
case(counter_ssl)
    0: en_ssl = 4'b1000;
    1: en_ssl = 4'b0100;
    default:en_ssl = 4'b0100;
endcase
end

always@(*)//////ssl 顯示
begin
ssl = 0;
if(en_ssl == 4'b1000)begin
    case(mode)
        1:ssl = 8'b01100000;/////level 1
        0:ssl = 8'b11011010;/////level 2
        default:ssl = 8'b11011010;
    endcase
    end
else if(en_ssl == 4'b0100)begin
    case(life)
        2:ssl = 8'b11011010;////////2
        1:ssl = 8'b01100000;/////////1
        0:ssl = 8'b11111100;//////0
        default:ssl = 8'b11111100;
    endcase
    end
else ssl = 8'b11101110;
end

always@(*)//////life
begin
    case(j)
        0: life = 2'b10;
        1: life = 2'b01;
        2: life = 2'b0;
    default life = 2'b0;
    endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////2020/6/20
always@(posedge clk_segr , negedge rst)///////counter of en_ssr
begin
if(!rst)
    counter_ssr <= 0;
else
    counter_ssr <= counter_ssr + 1;
end
always@(*)///////en_ssr
begin
case(counter_ssr)
    0: en_ssr = 4'b1000;
    1: en_ssr = 4'b0100;
    2: en_ssr = 4'b0010;
    3: en_ssr = 4'b0001;
    default: en_ssr = 4'b1110;
endcase
end

always@(*)//////ssr 顯示
begin
ssr = 0;
if(en_ssr == 4'b1000)begin//生命顯示
    case(life)
        2:ssr = 8'b01100000;///1
        1:ssr = 8'b01100000;/////1
        0:ssr = 8'b11111100;/////0
        default:ssr = 8'b11111100;
    endcase
    end
else if(en_ssr == 4'b0100)begin///遊戲中與否
    case(ns)
        run:ssr = 8'b11111100;//////0 遊戲中
        default ssr = 8'b01100000;/////1
    endcase
    end
else if(en_ssr == 4'b0010)begin/////答對分數 十位數
    case(i)
        0,1,2,3,4,5,6,7,8,9:ssr = 8'b11111100;
        10,11,12,13,14,15,16,17,18,19:ssr = 8'b01100000;/////1
        20,21,22,23,24,25,26,27,28,29:ssr = 8'b11011010;/////2
        30,31,32,33,34,35,36,37,38,39:ssr = 8'b11110010;/////3
        default ssr = 8'b11101110;
    endcase
end
else if(en_ssr == 4'b0001)begin/////////答對分數 個位數
    case(i)
        0,10,20,30:ssr = 8'b11111100;/////0
        1,11,21,31:ssr = 8'b01100000;/////1
        2,12,22,32:ssr = 8'b11011010;/////2
        3,13,23,33:ssr = 8'b11110010;/////3
        4,14,24,34: ssr = 8'b01100110;/////4
        5,15,25,35: ssr = 8'b10110110;/////5
        6,16,26,36: ssr = 8'b10111110;//////6
        7,17,27,37: ssr = 8'b11100000;//////7
        8,18,28,38: ssr = 8'b11111110;//////8
        9,19,29,39: ssr = 8'b11110110;/////9
        default ssr = 8'b11101110;
    endcase
end
else ssr = 8'b11101110;
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////2020.6.20 13:39  button 

    



always@(posedge clk or negedge rst)/////R s1
begin       
if(!rst)
begin
    timerR <= 0; //計數清零
    stateR <= 0;   //狀態清零
    R <= 0;//pulse清零
    end
else begin
    if(mode == 1)begin
        case(stateR)
            0:begin
                if(timerR < 15000000)//未到Max計數
                begin
                    if(s1)
                    begin
                        timerR <= timerR + 1;
                    end             
                    else begin
                        timerR <= 0;
                    end
                 end

else//確定按下
begin
    R <= 1;////pulse
    timerR <= 0;//計數清0
    stateR <= 1;//jump to next state
end
end
1:begin
    R<=0;//pulse 清           
    if(!s1)
         stateR <= 0;//wait for next hit
end
default:stateR <= 0;
endcase
end
else if (mode == 0)begin
    if (flag) 
        case (ps2_byte)
            8'h2D: R <= 1; //R
        default: R <= 0; 
        endcase  
    else if (R) R <= 0;  ///R再次出現時清0
end
end
end
//////////////E   s0
always@(posedge clk or negedge rst)
begin       
if(!rst)
begin
    timerE <= 0; //計數清零
    stateE <= 0;   //狀態清零
    E<=0;//pulse清零
    end
else begin
    if(mode == 1)begin
        case(stateE)
            0:begin
                if(timerE < 15000000)//未到Max計數
                begin
                    if(s0)
                    begin
                        timerE <= timerE + 1;
                    end             
                    else begin
                        timerE <= 0;
                    end
                end

                else//確定按下
                begin
                    E<=1;////pulse
                    timerE <= 0;//計數清0
                    stateE <= 1;//jump to next state
                end
            end
            1:begin
                E<=0;//pulse 清           
                if(!s0)
                    stateE <= 0;//wait for next hit
            end
            default:stateE <= 0;
            endcase
            end
else if (mode == 0)begin
    if (flag) 
        case (ps2_byte)
            8'h24: E <= 1; //E
        default: E <= 0; 
        endcase  
    else if (E) E <= 0;  
end
end
end
///////W s3
always@(posedge clk or negedge rst)
begin       
if(!rst)
begin
    timerW <= 0; //計數清零
    stateW <= 0;   //狀態清零
    W <= 0;//pulse清零
end
else begin
    if(mode == 1)begin
        case(stateW)
            0:begin
                if(timerW < 15000000)//未到Max計數
                begin
                    if(s3)
                    begin
                        timerW <= timerW + 1;
                    end             
                    else begin
                        timerW <= 0;
                    end
                end
                else//確定按下
                begin
                    W <= 1;////pulse
                    timerW <= 0;//計數清0
                    stateW <= 1;//jump to next state
                end
            end
            1:begin
                W <= 0;//pulse 清           
                if(!s3)
                    stateW <= 0;//wait for next hit
            end
            default:stateW<=0;
            endcase
end
else if (mode == 0)begin
    if (flag)
        case (ps2_byte)
            8'h1D: W <= 1; //W
        default: W <= 0; 
        endcase  
    else if (W) W <= 0;  
end
end
end
/////Q S4
always@(posedge clk or negedge rst)
begin       
if(!rst)
begin
    timerQ <= 0; //計數清零
    stateQ <= 0;   //狀態清零
    Q <= 0;//pulse清零
    end
else begin
if(mode == 1)begin
    case(stateQ)
        0:begin
            if(mode == 1 && timerQ < 15000000)//未到Max計數
            begin
                if(s4)
                begin
                    timerQ <= timerQ + 1;
                end             
                else begin
                    timerQ <= 0;
                end
            end
            else//確定按下
            begin
                Q <= 1;////pulse
                timerQ <= 0;//計數清0
                stateQ <= 1;//jump to next state
            end
        end
        1:begin
            Q <= 0;//pulse 清           
            if(!s4)
            stateQ <= 0;//wait for next hit
        end
        default:stateQ <= 0;
        endcase
        end
else if (mode == 0)begin
    if (flag) //flag為1時 輸出 內部訊號
        case (ps2_byte)
            8'h15: Q <= 1; //Q
        default: Q <= 0; 
        endcase  
    else if (Q) Q <= 0;  
end
end
end
always@(posedge clk , negedge rst)/////////////S2 counter start
begin
if (!rst)
    counters2 <= 0;
else if(s2 == 1)
    counters2 <= counters2 + 1;
else if(s2 == 0)
    counters2 <= 0;
end
always@(*)
begin
if(counters2 > 2000000)
        start = 1;
else
        start = 0;
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////答錯答對
always@(posedge clk , negedge rst)//////////////正確的trigger i  輸入正確時 i + 1
begin
if(!rst)
    i <= 0;
else if((mode == 1 &&  cs == run && ((i == 0 && R) || (i == 1 && E) || (i == 2 && W) || (i == 3 && Q))))
    i <= i + 1;
else if (mode == 0 && cs == run && ( (counterA < 3 && A ) ||//A
(counterD < 1 && counterA == 3 && D) || //D
(counterE < 3 && counterD == 1 && E) || //E
(counterF < 2 && counterE == 3 && F) || //F
(counterQ < 2 && counterF == 2 && Q) || //Q
(counterR < 1 && counterQ == 2 && R) || //R
(counterS < 3 && counterR == 1 && S) || //S
(counterW < 5 && counterS == 3 && W) //W
))
    i <= counterA + counterS + counterD + counterF + counterQ + counterW + counterE + counterR + 1;
end

always@(posedge clk , negedge rst)///////////錯誤的trigger , 輸入錯誤時 j + 1
begin
if(!rst)
    j <= 0;
else if((mode == 1 && cs == run && (i == 0 && ((~R) && (E || W || Q))) || (i == 1 && ((~E) && (R || W || Q))) || (i == 2 && ((~W) && (R || E || Q)))|| (i == 3 && ((~Q) && (R || E || W)))))
    j <= j + 1;
else if(mode == 0 && cs == run && ( ((counterA < 3 && (D || E || F || Q || R || S || W)) || //要按A
(counterD < 1 && counterA == 3 && (A || E || F || Q || R || S || W)) || //要按D
(counterE < 3 && counterD == 1 && (A || D || F || Q || R || S || W)) || //要按E
(counterF < 2 && counterE == 3 && (A || D || E || Q || R || S || W)) || //要按F
(counterQ < 2 && counterF == 2 && (A || D || F || E || R || S || W)) || //要按Q
(counterR < 1 && counterQ == 2 && (A || D || F || Q || E || S || W)) || //要按R
(counterS < 3 && counterR == 1 && (A || D || E || Q || R || F || W)) || //要按S
(counterW < 4 && counterS == 3 && (A || D || E || Q || R || S || F)) //要按W
) 
) )
    j <= j + 1;
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////FSM
always@(posedge clk , negedge rst)//////////cs
begin
if(!rst)
    cs <= 0;
else cs <= ns;
end

always@(*)///////////////////ns
begin
ns = stop;
case(cs)
stop:begin
    if(start)
        ns = run;
    else ns = stop;
end
run:begin
    if(life == 0)
        ns = die;
    else if(life > 0 && counter_led == 16)
        ns = win;
    else if(mode == 1 && i == 4 && counter_led == 16)///////////答對4個 時間到 win~~~
        ns = win;
    else if (mode == 0 && i == 20 && counter_led == 16)////答對20個 時間到 win~~~
        ns = win;
    else ns = run;
end
win:ns = win;
die:ns = die;
endcase
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////led

always@(posedge clk_led , negedge rst)//////遊戲中led的counter每秒+1
begin
if(!rst)
    counter_led <= 0;
else if(ns == run)
    counter_led <= counter_led + 1;
else counter_led <= counter_led;
end

always@(*)/////////////led 顯示
begin
case(counter_led)
    0:led = 16'b1111_1111_1111_1111;
    1:led = 16'b0111_1111_1111_1111;
    2:led = 16'b0011_1111_1111_1111;
    3:led = 16'b0001_1111_1111_1111;
    4:led = 16'b0000_1111_1111_1111;
    5:led = 16'b0000_0111_1111_1111;
    6:led = 16'b0000_0011_1111_1111;
    7:led = 16'b0000_0001_1111_1111;
    8:led = 16'b0000_0000_1111_1111;
    9:led = 16'b0000_0000_0111_1111;
    10:led = 16'b0000_0000_0011_1111;
    11:led = 16'b0000_0000_0001_1111;
    12:led = 16'b0000_0000_0000_1111;
    13:led = 16'b0000_0000_0000_0111;
    14:led = 16'b0000_0000_0000_0011;
    15:led = 16'b0000_0000_0000_0001;
    16:led = 16'b0;
    default: led = 16'b0;
endcase
end
//////////////////////////////////////////////////////////////////////////////////////////////////ps2鍵盤輸入 短暫,長按


always @ (posedge clk or negedge rst)
if (!rst)
    {ps2_clk0, ps2_clk1, ps2_clk2} <= 3'd0;
else begin
    ps2_clk0 <= ps2_clk;
    ps2_clk1 <= ps2_clk0;
    ps2_clk2 <= ps2_clk1;
end

assign ps2_clk_neg = ~ps2_clk1 & ps2_clk2;

///
always @ (posedge clk or negedge rst)
begin
if (!rst)
begin
    num <= 4'd0;
    data_temp <= 8'd0;
end

else if (ps2_clk_neg)
begin
    if (num == 0) 
        num <= num + 1'b1;//跳過初始
    else if (num <= 8) 
    begin
        num <= num + 1'b1;
        data_temp[num-1] <= ps2_data;
    end
    else if (num == 9) 
        num <= num + 1'b1;
    else 
        num <= 4'd0; //清0
    end
end

///
always@(posedge clk or negedge rst)
begin
if (!rst)
begin
    ps2_state <= 1'b0;
    ps2_loosen <= 1'b0;
    ps2_byte <= 0;
end
else if (num == 4'd10)
        if (data_temp == 8'hf0) 
            ps2_loosen <= 1'b1;
        else begin
            if (ps2_loosen) //清0
            begin
                ps2_state <= 1'b0;
                ps2_loosen <= 1'b0;
            end
            else begin
                ps2_state <= 1'b1;
                ps2_byte <= data_temp; //取到訊號輸入給 ps2_byte存
            end
        end
end

//////////////久按

always@(posedge clk)begin
ps2state_reg <= ps2_state;
end
assign flag = (ps2state_reg) & (~ps2_state);


////
always @ (posedge clk or negedge rst)////////////////鍵盤訊號轉換成ASDF
begin
if (!rst)
    begin A <= 0; S <= 0; D <= 0; F <= 0; end
else if(mode == 0)begin
if (flag) 
case (ps2_byte)
    8'h1C: A <= 1; //A
    8'h1B: S <= 1; //S
    8'h23: D <= 1; //D
    8'h2B: F <= 1; //F
    default: begin A <= 0; S <= 0; D <= 0; F <= 0; 
 end
    endcase
    else if (A) A <= 0;
    else if (S) S <= 0;
    else if (D) D <= 0;
    else if (F) F <= 0;
end
end

///////////////////////////////////////////////////////////按鍵按了幾次
always@(posedge clk , negedge rst) /////計數A按的次數
begin
if(!rst)
    counterA <= 0;
else if(cs == run && A && counterA < 3)
    counterA <= counterA + 1;
end

always@(posedge clk , negedge rst) /////計數S按的次數
begin
if(!rst)
    counterS <= 0;
else if(cs == run && S && counterR == 1 && counterS < 3 )
    counterS <= counterS + 1;

end

always@(posedge clk , negedge rst) /////計數D按的次數
begin
if(!rst)
    counterD <= 0;
else if(cs == run && D && counterA == 3 && counterD < 1)
    counterD <= counterD + 1;
end

always@(posedge clk , negedge rst) /////計數F按的次數
begin
if(!rst)
    counterF <= 0;
else if(cs == run && F && counterE == 3 && counterF < 2)
    counterF <= counterF + 1;
end

always@(posedge clk , negedge rst) /////計數Q按的次數
begin
if(!rst)
    counterQ <= 0;
else if(cs == run && Q && counterF == 2 && counterQ < 2 )
    counterQ <= counterQ + 1;
end

always@(posedge clk , negedge rst) /////計數W按的次數
begin
if(!rst)
    counterW <= 0;
else if(cs == run && W && counterS == 3 && counterW < 5)
    counterW <= counterW + 1;
end

always@(posedge clk , negedge rst) /////計數E按的次數
begin
if(!rst)
    counterE <= 0;
else if(cs == run && E && counterD == 1 && counterE < 3)
    counterE <= counterE + 1;
end

always@(posedge clk , negedge rst) /////計數R按的次數
begin
if(!rst)
    counterR <= 0;
else if(cs == run && R && counterQ == 2 && counterR < 1) 
    counterR <= counterR + 1;   
end


endmodule



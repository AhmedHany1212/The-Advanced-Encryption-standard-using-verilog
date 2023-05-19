module Ser_to_Para_tb;
 // Inputs
 reg in;
 reg clk;
 reg rst;
 reg en;
 // Outputs
 wire [7:0] out;
 wire DataValid;
 
 
 initial 
  begin
   $dumpfile("Ser_to_Para.vcd");
   $dumpvars;
  
   // Initialize Inputs
   clk = 0;
   rst = 0;
   en  = 0;
   
   #10 rst = 1;
   
   //8'b00010101 = 8'h15
   wait(clk);
   en = 1;
   #40 in=1;
   #40 in=0;
   #40 in=1;
   #40 in=0;
   #40 in=1;
   #40 in=0;
   #40 in=0;
   #40 in=0; 
         
   //8'b11111111 = 8'bff
   #40 in=1;
   #40 in=1;
   #40 in=1;
   #40 in=1;
   #40 in=1;
   #40 in=1;
   #40 in=1;
   #40 in=1;
   
   //8'b11001000 = 8'hc8
   #40 in=0;
   #40 in=0;
   #40 in=0;
   #40 in=1;
   #40 in=0;
   #40 in=0;
   #40 in=1;
   #40 in=1;
   #40
   en = 0;
   #100
   $finish;
  end
	
 always #20 clk=~clk;

 // Instantiate the Design Under Test (DUT)
 Ser_to_Para DUT (
  .in(in), 
  .clk(clk), 
  .rst(rst),
  .en(en),
  .out(out),  
  .DataValid(DataValid)
 );
 
endmodule
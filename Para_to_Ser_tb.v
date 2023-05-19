module Para_to_Ser_tb;
 // Inputs
 reg [7:0] DataIN;
 reg clk;
 reg RST;
 reg enable;
 
 // Outputs
 wire DataOUT;
 wire Done_flage;
 
 always #10 clk=~clk;
 
 initial 
  begin
   $dumpfile("Para_to_Ser.vcd");
   $dumpvars;
   
   // Initialize Inputs
   DataIN = 1'b0;
   clk = 1'b0;
   RST = 1'b0;
   enable = 1'b0;
   
   // Wait 100 ns for global reset to finish
   #20 RST=1'b1;
   
   #10
   // Add stimulus here
   enable=1'b1;
   DataIN=8'b00101011;
   wait (Done_flage);
   
   #20;
   DataIN=8'hc3;// 1100,0011
   #20;
   wait (Done_flage);
   
   #20
   enable=1'b0;
   #100
   $finish ;  
  end
  
 // Instantiate the Design Under Test (DUT)
 Para_to_Ser DUT (
  .DataIN(DataIN), 
  .clk(clk), 
  .RST(RST), 
  .enable(enable), 
  .DataOUT(DataOUT),.Done_flage(Done_flage)
 );
       
endmodule
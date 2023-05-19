//input 1bit - clk - rst 
//output 8bit reg  ,data valid
//counter 
//standard  


module Ser_to_Para(
 input 					in,
 input 					clk,rst,
 input					en,
 output	reg		[7:0]   out,
 output	reg       		DataValid 
 );

 reg	[7:0]	preout;
 reg	[2:0]   count;
 
 
 always@(posedge clk,negedge rst)
  begin
   if(!rst) 
    begin
     out<=8'b0;
     preout <=8'b0;
     count<=1'b0;
     DataValid<=1'b0;
    end 
   else if(en)
    begin 
     if(count==3'b111)
      begin 
       count<=3'b0;
       out<={in , preout[7:1]};
       DataValid<=1;
      end
     else 
      begin
       preout<={in , preout[7:1]};	 
       DataValid<=1'b0;	
       count<=count+1'b1;
      end
    end 
  end
  
endmodule
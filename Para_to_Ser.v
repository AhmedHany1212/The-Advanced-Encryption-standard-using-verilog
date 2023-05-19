module Para_to_Ser(
 input  wire [7:0] DataIN,
 input  wire       clk,RST,enable,
 output reg        DataOUT,
 output reg        Done_flage    
 );
 
 reg           [2:0]    count;
 
 
 always @(posedge clk , negedge RST)
  begin 
   if(!RST )
    begin
     DataOUT<=1'b0;
     count<=4'b000;
	 Done_flage <= 1'b0;
    end
   else if(enable)
    begin
	 if(count==3'b111)
      begin
       DataOUT<=DataIN[count];
  	   count<= 3'b0;
	   Done_flage <= 1'b1;
      end
	 else
	  begin
	   DataOUT<=DataIN[count];
	   count<= count + 1'b1;
	   Done_flage <= 1'b0;
	  end
	end  
  end
 
endmodule
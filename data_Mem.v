module data_Mem (
 input	wire [7:0] 	DataIN,
 input	wire [3:0] 	Add,
 input	wire      	CLK,RST,
 input 	wire       	CS, 
 input  	wire [1:0] 	RWSM, //read(00) write(01) shift(10) mix(11) 
 output 	reg  [7:0] 	DataOUT
 );
 
 
 reg		[7:0]   memory	[3:0]	[3:0];
 reg 	[7:0]   trans;
 wire 	[7:0]   transOut;
 
 integer i,j;
 
 
 
 always@(posedge CLK or negedge RST)
  begin
   if(!RST) 
    begin 
     initialize();
    end
   else if((CS==1'b1) && (RWSM==2'b00)) //read
    begin 
     DataOUT <= memory[Add[3:2]][Add[1:0]];
    end 
   else if((CS==1'b1) && (RWSM==2'b01)) //write
    begin
     memory[Add[3:2]][Add[1:0]] <= transOut;
    end	
   else if((CS==1'b1) && (RWSM==2'b10)) //shift - rotate
    begin
 	memory[1][0] <= memory[1][1];
 	memory[1][1] <= memory[1][2];
 	memory[1][2] <= memory[1][3];
 	memory[1][3] <= memory[1][0];
 
 	memory[2][0] <= memory[2][2];
 	memory[2][2] <= memory[2][0];
 	memory[2][1] <= memory[2][3];
 	memory[2][3] <= memory[2][1];
 		
 	memory[3][3] <= memory[3][2];
 	memory[3][2] <= memory[3][1];
 	memory[3][1] <= memory[3][0];
 	memory[3][0] <= memory[3][3];
    end
    else if((CS==1'b1) && (RWSM==2'b11)) //Mix column
     begin
 	 for(i=0;i<=3;i=i+1)
 	  memory[0] [i] <= mult_two(memory[0][i]) ^ mult_three(memory[1][i]) ^memory[2][i] ^ memory[3][i];
 	  
 	 for(i=0;i<=3;i=i+1)
 	  memory[1] [i] <= memory[0][i] ^ mult_two(memory[1][i]) ^ mult_three(memory[2][i]) ^ memory[3][i];
 	  
 	 for(i=0;i<=3;i=i+1)
 	  memory[2] [i] <= memory[0][i] ^ memory[1][i] ^ mult_two(memory[2][i]) ^ mult_three(memory[3][i]);
 	  
 	 for(i=0;i<=3;i=i+1)
 	  memory[3] [i] <= mult_three(memory[0][i]) ^ memory[1][i] ^memory[2][i] ^ mult_two(memory[3][i]);
 	end
  end
 
 always@(*)
  begin
   trans = DataIN;
  end
 
 
 function [7:0] mult_two ;
    input  	[7:0]	 x;
    begin
     if(x[7]==1) mult_two = {x[6:0] , 1'b0} ^ 8'h1b;
     else 		mult_two = {x[6:0] , 1'b0}; 
    end
 endfunction
 
 
 function [7:0] mult_three ;
    input 	[7:0]	 x;
    begin
     mult_three = mult_two(x) ^ x;  		
    end                                           
 endfunction
 
 
 
 task initialize;
  integer i,j;
  begin
   for(i=0;i<=3;i=i+1)
     for(j=0;j<=3;j=j+1)
 	  memory [i][j] <= 1'b0; 
  end
 endtask
 
 
  aes_sbox DUT(
   .sboxw(trans),
   .new_sboxw(transOut)
  );
  
  
 
endmodule
module Cipher_Mem(
 input	wire	[7:0]	DataIN,
 input	wire			CLK,RST,
 input	wire			RW,     //read=1;write =0
 input 	wire    		cs, 
 input	wire	[3:0]	address,
 input	wire			operation,  //flags
 output	reg		[7:0]	DataOut
 );
 
 reg	[7:0]	memory		[3:0] [3:0];
 reg	[7:0]	memory_comp	[3:0] [3:0];
 reg	[7:0]	temp		[3:0];
 reg [7:0]   trans;
 wire[7:0]   transOut;
 
 integer x,y;
 
 
  
 
 always@(posedge CLK or negedge RST) 
  begin
   if(!RST)
 	begin
 	 initialize();
 	end
   else if(cs && !operation) 
    begin
 	if(!RW)   //write
 	 begin
 	  memory[address[3:2]] [address[1:0]] <= DataIN;  //row then column
 	  if(address[3:0] ==4'b0111)
 	   temp[00] <= transOut ^ 8'b1;
 	  else if (address[1:0] == 2'b11)
 	   temp[address [3:2] - 2'b1] <= transOut;
 	 end
 	else     //read
 	 DataOut <= memory[address[3:2]] [address[1:0]];
    end	 
   else if(cs && operation)
   begin
    for(y=0;y<=3;y=y+1)
     for(x=0;x<=3;x=x+1)
      memory[x] [y] <= memory_comp [x] [y];
   end
  end
 
  always@(*)
   begin
    trans = DataIN;
   end
 
 always@*
  begin 
     for(x=0;x<=3;x=x+1)
 	 memory_comp [x] [0] =memory[x][0] ^ temp[x];
 	for(x=0;x<=3;x=x+1)
 	 memory_comp [x] [1] =memory[x][1] ^ memory[x][0] ^ temp[x];
 	for(x=0;x<=3;x=x+1)
 	 memory_comp [x] [2] =memory[x][2] ^ memory[x][1] ^ memory[x][0] ^ temp[x];
 	for(x=0;x<=3;x=x+1)
 	 memory_comp [x] [3] =memory[x][3] ^ memory[x][2] ^ memory[x][1] ^ memory[x][0] ^ temp[x];
  end 
 	
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
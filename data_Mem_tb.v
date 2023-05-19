module data_Mem_tb ();

 reg [7:0] 		DataIN_tb;
 reg [3:0] 		Add_tb;
 reg      		CLK_tb,RST_tb; 
 reg       		CS_tb; 
 reg [1:0] 		RWSM_tb; //read(00) write(01) shift(10) mix(11)
 wire  [7:0]	DataOUT_tb;
 
 parameter clock_per = 20;
 
 integer i;
 
 reg  [7:0]    memory     [15:0];
 reg  [7:0]    sbox_mem   [15:0];
 reg  [7:0]    shift_mem  [15:0];
 reg  [7:0]    mix_mem    [15:0];
 
 reg  [15:0]   address = 4'b0;
 
 always #10 CLK_tb = ~CLK_tb;
 
 initial
  begin
   $dumpfile("data_Mem.vcd");
   $dumpvars;
   
   $readmemh("E:\initial_data.txt",memory);
   $readmemh("E:\sbox_data.txt",sbox_mem);
   $readmemh("E:\shift_row.txt",shift_mem);
   $readmemh("E:\mix_column.txt",mix_mem);
   
   initialize();
   
   Reset();
   
   for(i=0;i<=15;i=i+1)
    begin
     input_data(memory[i],address);
	 address = address + 4'b1;
    end
	#clock_per
	
   //-------------test 1--read and write ----------//
   $display("test 1--read and write");
   address = 4'b00;
   for(i=0;i<=15;i=i+1)
    begin
     output_data(memory[i],address);
	 address = address + 4'b1;
    end
	
	
   //-------------test 2-- sbox translate ----------//
   
   $display("test 2--sboxing");
   address = 4'b00;
   for(i=0;i<=15;i=i+1)
    begin
     output_data(sbox_mem[i],address);
	 address = address + 4'b1;
    end
	#clock_per
	
   //-------------test 3-- shift coloumn ----------//
   shifting();
   $display("test 3--shift coloumn");
   address = 4'b00;
   for(i=0;i<=15;i=i+1)
    begin
     output_data(shift_mem[i],address);
	 address = address + 4'b1;
    end
	#clock_per
  
	
	//-------------test 4-- mix  coloumn ----------//
   mixing();
   $display("test 4--mix coulmn");
   address = 4'b00;
   for(i=0;i<=15;i=i+1)
    begin
     output_data(mix_mem[i],address);
	 address = address + 4'b1;
    end
   #100
   $finish;
  end
  
  
 /////////////////tasks////////////////////////////
 
 task initialize;
  begin
   CS_tb  = 1'b0;
   CLK_tb = 1'b1;
   RST_tb = 1'b1;
  end
 endtask
  
 task Reset;
  begin
   RST_tb = 1'b1;
   #10
   RST_tb = 1'b0;
   #10
   RST_tb = 1'b1;
  end
 endtask
 
 task input_data;
 input [7:0]  input_D;
 input [3:0]  addres;
 begin
  DataIN_tb = input_D;
  #clock_per
  Add_tb    = addres;
  CS_tb		= 1'b1;
  RWSM_tb	= 2'b01;
 end
 endtask
 
 task output_data;
 input [7:0]  output_D;
 input [3:0]  addres;
 begin
  CS_tb		= 1'b1;
  RWSM_tb	= 2'b00;
  Add_tb    = addres;
  #clock_per
  if(DataOUT_tb==output_D)
   $display("%h= %h at %d",DataOUT_tb,output_D,i);
  else
   $display("%h ~= %h at %d",DataOUT_tb,output_D,i);  
 end
 endtask 
 
  
 task shifting;
  begin
   #clock_per
   CS_tb		= 1'b1;
   RWSM_tb		= 2'b10;
   #clock_per
   CS_tb		= 1'b0;
  end
 endtask
 
 task mixing;
  begin
   #clock_per
   CS_tb		= 1'b1;
   RWSM_tb		= 2'b11;
   #clock_per
   CS_tb		= 1'b0;
  end
 endtask
 
 data_Mem DUT(
 .DataIN(DataIN_tb),
 .Add(Add_tb),
 .CLK(CLK_tb),
 .RST(RST_tb), 
 .CS(CS_tb),
 .RWSM(RWSM_tb),
 .DataOUT(DataOUT_tb)
 );
 
 endmodule
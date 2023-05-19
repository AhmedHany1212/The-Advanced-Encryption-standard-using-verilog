module cipher_memory_tb();
 		reg			[7:0]	DataIN_tb  ;
 		reg					CLK_tb,RST_tb;
 		reg					RW_tb;     //read=1;write =0
  	    reg    				cs_tb; 
 		reg			[3:0]	address_tb;
 		reg					operation_tb;  //flags
       wire			[7:0]	DataOut_tb;
	

reg [7:0] cipher_mem [15:0];
reg [7:0] round      [15:0];
integer i;
reg [7:0] add;



always #10 CLK_tb=~CLK_tb;

initial 
 begin 
    $dumpfile("Cipher_mem.vcd");    
    $dumpvars; 
	$readmemh("E:\cipher_initial.txt",cipher_mem);    
	$readmemh("E:\cipher_operation.txt",round);
	initialize();
	Reset();
	//write data
	for(i=0;i<16;i=i+1)
	 begin 
		data_input(cipher_mem[i],add);
		add=add+1;
	 end
	#20 cs_tb=0;
	
	//read data 
	$display("test 1--read and write");
	add=0;
	for(i=0;i<16;i=i+1)
	 begin 
		data_output(cipher_mem[i],add);
		add=add+1;
	 end
	
	#20 cs_tb=0;
	#40
	
	operation();
	
	$display("test 2--operation");
	add=0;
	for(i=0;i<16;i=i+1)
	 begin 
		data_output(round[i],add);
		add=add+1;
	 end
	
	
 $finish;
 end
//<>

 task initialize;
  begin
   RST_tb = 1'b1;
   cs_tb  = 1'b0;
   CLK_tb = 1'b1;
   add=0;
  end
 endtask

 task Reset;
  begin
   RST_tb = 1'b1;
   #5
   RST_tb = 1'b0;
   #5
   RST_tb = 1'b1;
  end
 endtask

task data_input;
  input [7:0] data; 
  input [3:0] add;
  integer i;
 begin 
    #20;
    DataIN_tb=data;  	
	cs_tb=1;
	operation_tb=0;
	RW_tb=0;
	address_tb=add;
 end
endtask

task data_output;
 input [7:0] compared_data;
 input [3:0] add;
  begin 
    address_tb=add;
    cs_tb=1;
    operation_tb=0;
    RW_tb=1;
    #20;
	if(DataOut_tb==compared_data) 
	   $display("1 %h= %h",DataOut_tb,compared_data);	
	else 
	   $display("0 %h ~ %h",DataOut_tb,compared_data);
  end 
endtask

task operation;
 begin 
    cs_tb=1;
	operation_tb=1;
	#20;
	operation_tb=0;
	cs_tb=0;
 end 
 endtask
 
 Cipher_Mem DUT(
 .DataIN(DataIN_tb),
 .address(address_tb),
 .CLK(CLK_tb),
 .RST(RST_tb), 
 .cs(cs_tb),
 .RW(RW_tb),
 .operation(operation_tb),
 .DataOut(DataOut_tb)
 );
 
 
endmodule
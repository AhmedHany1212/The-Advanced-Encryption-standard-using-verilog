module control_unit(
 input		wire			DataIN_mem,DataIN_cipher,
 input 		wire	     	clock,Reset,
 input  	wire			Data_Valid,
 output		reg				DataOUT,
 output		reg				Busy,valid_out
 );
 
 
//////////////////////////////////////////////////////////
////////////////////internal_signal///////////////////////
//////////////////////////////////////////////////////////

 reg	[3:0]   item_count;
 reg         	en_it_count;
 reg			Res_1;
 
 reg	[3:0]   r_count;
 reg         	en_r_count;
 reg			Res_2;
 
 reg	[7:0]	C_DataIn;
 reg			C_cs,C_RW,C_op;
 wire	[7:0]	C_DataOut;
 
 reg	[7:0]	D_DataIn;
 reg			D_cs;
 reg	[1:0]	D_RWSM;
 reg	[7:0]	D_DataOut;
 
 reg			D_en_StoP;
 wire			D_StoP_done;
 wire	[7:0]	D_StoP_Out;
 
 reg			C_en_StoP;
 wire			C_StoP_done;
 wire	[7:0]	C_StoP_Out;
 
 reg			en_PtoS;
 wire			PtoS_done;


//////////////////////////////////////////////////////////
////////////////////FSM_control_unit//////////////////////
//////////////////////////////////////////////////////////

 // states
 localparam	[2:0]	Idle			= 3'b000,
					start_state		= 3'b001,
					shift_Rotate	= 3'b011,
					Mix_column		= 3'b100,
					write_state		= 3'b101,
					read_state		= 3'b010,
					Out_State		= 3'b110;
 
 
 reg	[2:0]	current_state, next_state;

 // state transation
 always@(posedge clock, posedge Reset)
  begin
   if(Reset)
    current_state<=Idle;
   else
    current_state<=next_state;
  end
 
 // next state
 always@(*)
  begin
   case(current_state)
   	Idle			:	begin
						 if(Data_Valid)
						 next_state = start_state;
						 else 
						 next_state = Idle;
						end
						
   	start_state			:	begin //write xor counter16
						 if(item_count==4'b1111)
						  next_state = shift_Rotate;
						 else 
						  next_state = start_state;	
						end
						
   	shift_Rotate	:	begin
						 if(r_count == 4'b1001)
						  next_state = Out_State;
						 else if(r_count==4'b1000)
						  next_state = read_state;
						 else 
						  next_state = Mix_column;
						end
						
   	Mix_column		:	begin
						  next_state = read_state;
						end
						
   	read_state		:	begin
						  next_state = write_state;
						end
						 
	write_state	:	begin
						 if(item_count==4'b1111)
						  next_state = shift_Rotate;
						 else
						  next_state = read_state;
						end	
						
   	Out_State		:	begin
						 if(item_count==4'b1111&&PtoS_done)
						  next_state = Idle;
						 else if(PtoS_done)
						  next_state = read_state;
						 else 
						  next_state = Out_State;
						end
						
   	default			:	begin
						  next_state = Idle; 
						end
   endcase
  end
 
 //next state logic
 always@(*)
  begin
   case(current_state)
   	Idle			:	begin
						 D_DataIn = C_StoP_Out ^ D_StoP_Out;
						 D_en_StoP	 = 1'b0;
						 C_en_StoP	 = 1'b0;
						 en_it_count = 1'b0;// count 16 
						 en_r_count = 1'b0;
						 en_PtoS  = 1'b0;
						 D_RWSM = 2'b00;
						 D_cs = 1'b0;
						 C_RW = 1'b1;
						 C_cs = 1'b0;
						 C_op = 1'b0;
						 Res_1 = 1'b0;
						 Res_2 = 1'b0;
						 Busy = 1'b0;
						 valid_out = 1'b0;
						end
						
   	start_state		:	begin
						 D_DataIn = C_StoP_Out ^ D_StoP_Out;
						 D_en_StoP	 = 1'b1;
						 C_en_StoP	 = 1'b1;
						 en_r_count = 1'b0;
						 en_PtoS  = 1'b0;
						 Res_1 = 1'b1;
						 Res_2 = 1'b1;
						 Busy = 1'b1;
						 valid_out = 1'b0;
						 if(D_StoP_done && C_StoP_done)
						  begin
						   en_it_count= 1'b1;// count 16
						   D_RWSM = 2'b01;
						   D_cs = 1'b1;
						   C_RW = 1'b1;
						   C_cs = 1'b1;
						   C_op = 1'b0;
						  end
						 else
						  begin
						   en_it_count = 1'b0;// count 16
						   D_RWSM = 2'b01;
						   D_cs = 1'b0;
						   C_RW = 1'b1;
						   C_cs = 1'b0;
						   C_op = 1'b0;
						  end
						end
   		
   	shift_Rotate	:	begin
						 D_DataIn = C_DataOut ^ D_DataOut;
						 D_en_StoP   = 1'b0;
						 C_en_StoP   = 1'b0;
						 en_it_count = 1'b0;
						 en_r_count = 1'b1;
						 en_PtoS  = 1'b0;
						 D_RWSM = 2'b10;
						 D_cs = 1'b1;
						 C_RW = 1'b1;
						 C_cs = 1'b1;
						 C_op = 1'b1;
						 Res_1 = 1'b0;
						 Res_2 = 1'b1;
						 Busy = 1'b1;
						 valid_out = 1'b0;
						end
						
   	Mix_column		:	begin
						 D_DataIn = C_DataOut ^ D_DataOut;
						 D_en_StoP   = 1'b0;
						 C_en_StoP   = 1'b0;
						 en_it_count = 1'b0;
						 en_r_count = 1'b0;
						 en_PtoS  = 1'b0;
						 D_RWSM = 2'b11;
						 D_cs = 1'b1;
						 C_RW = 1'b1;
						 C_cs = 1'b1;
						 C_op = 1'b1;
						 Res_1 = 1'b1;
						 Res_2 = 1'b1;
						 Busy = 1'b1;
						end
						
   	read_state		:	begin 
						 D_DataIn = C_DataOut ^ D_DataOut;
						 D_en_StoP   = 1'b0;
						 C_en_StoP   = 1'b0;
						 en_it_count = 1'b0;
						 en_r_count = 1'b0;	
						 en_PtoS  = 1'b0;
						 D_RWSM = 2'b00;//read
						 D_cs = 1'b1; 
						 C_RW = 1'b1;
						 C_cs = 1'b1;
						 C_op = 1'b0;
						 Res_1 = 1'b1;
						 Res_2 = 1'b1;
						 Busy = 1'b1;
						 valid_out = 1'b0;
						end
						
   	write_state		:	begin 
						 D_DataIn = C_DataOut ^ D_DataOut;
						 D_en_StoP   = 1'b0;
						 C_en_StoP   = 1'b0;
						 en_it_count = 1'b1;
						 en_r_count = 1'b0;
						 en_PtoS  = 1'b0;
						 D_RWSM = 2'b01;//write
						 D_cs = 1'b1;
						 C_RW = 1'b1;
						 C_cs = 1'b0;
						 C_op = 1'b0;
						 Res_1 = 1'b1;
						 Res_2 = 1'b1;
						 Busy = 1'b1;
						 valid_out = 1'b0;
						end
						
   	Out_State		:	begin
						 D_DataIn = C_StoP_Out ^ D_StoP_Out;
						 D_DataIn = C_DataOut ^ D_DataOut;
						 D_en_StoP   = 1'b0;
						 C_en_StoP   = 1'b0;
						 en_PtoS  = 1'b1;
						 en_r_count = 1'b0;
						 Res_1 = 1'b1;
						 Res_2 = 1'b1;
						 Busy = 1'b1;
						 valid_out = 1'b1;
						 if(PtoS_done)
						  begin
						   en_it_count = 1'b1;
						   D_RWSM = 2'b00;//read
						   D_cs = 1'b1;
						   C_RW = 1'b1;
						   C_cs = 1'b1;
						   C_op = 1'b0;
						  end
						 else
						  begin
						   en_it_count = 1'b0;
						   D_RWSM = 2'b00;//read
						   D_cs = 1'b0;
						   C_RW = 1'b1;
						   C_cs = 1'b0;
						   C_op = 1'b0;
						  end
						end
						
   default			:	begin
						 D_en_StoP	 = 1'b0;
						 C_en_StoP	 = 1'b0;
						 en_it_count = 1'b0;// count 16 
						 en_r_count = 1'b0;
						 en_PtoS  = 1'b0;
						 D_RWSM = 2'b00;
						 D_cs = 1'b0;
						 C_RW = 1'b1;
						 C_cs = 1'b0;
						 C_op = 1'b0;
						 Res_1 = 1'b1;
						 Res_2 = 1'b1;
						 Busy = 1'b0;
						 valid_out = 1'b0;
						end
   endcase
  end
 
 
//////////////////////////////////////////////////////////
/////////////////////////Counters/////////////////////////
//////////////////////////////////////////////////////////


//item counter count from 0 to 16

 
 always@(posedge clock)
  begin
   if(!Res_1)//syncronus reset
    item_count <= 0;
   else if(en_it_count)
    item_count <= item_count+4'b1;
  end
 
//round counter count from 0 to 9
 
 
 always@(posedge clock)
  begin
   if(!Res_2)
    r_count <= 0;
   else if(en_r_count)
    r_count <= r_count+4'b1;
  end
  
//////////////////////////////////////////////////////////
////////////////////block instantiation///////////////////
////////////////////////////////////////////////////////// 
 

 Cipher_Mem C_M(
  DataIN(C_DataIn),
  CLK(clock),
  RST(Reset),
  RW(C_RW),     
  cs(C_cs), 
  address(item_count),
  operation(C_op),
  DataOut(C_DataOut)
 );
 
 
 
 data_Mem D_M(
  .DataIN(D_DataIn),
  .Add(item_count),
  .CLK(clock),
  .RST(Reset),
  .CS(D_cs), 
  .RWSM(D_RWSM),
  .DataOUT(D_DataOut)
 );

 

 Ser_to_Para D_StoP(
  .in(DataIN_mem), 
  .clk(clock),
  .rst(Reset),
  .en(D_en_StoP),
  .out(D_StoP_Out),
  .DataValid(D_StoP_done)
 );
 
 
 Ser_to_Para C_StoP(
  .in(DataIN_cipher), 
  .clk(clock),
  .rst(Reset),
  .en(C_en_StoP),
  .out(C_StoP_Out),
  .DataValid(C_StoP_done)
 );
 
 
 Para_to_Ser PtoS(
 .DataIN(D_DataOut ^ C_DataOut),
 .clk(clock),
 .RST(Reset),
 .enable(en_PtoS),
 .DataOUT(DataOUT),
 .Done_flage(PtoS_done)    
 );
endmodule
`include "timescale.v"
`include "wb_model_defines.v"

`define TIME $display("  Time: %0t", $time)

//Register Addreses 
`define plain0 8'h00
`define plain1 8'h04
`define plain2 8'h08
`define plain3 8'h0b
`define cipher0 8'h10
`define cipher1 8'h14
`define cipher2 8'h18
`define cipher3 8'h1b

`define AES_BASE              32'hd0000000


module aes_128_top_tb();

   // WISHBONE common
   reg           wb_clk;     // WISHBONE clock
   reg           wb_rst;     // WISHBONE reset
   wire [31:0] 	 wbs_aes_dat_i;     // WISHBONE data input
   wire [31:0] 	 wbs_aes_dat_o;     // WISHBONE data output
   // WISHBONE error output
   // WISHBONE slave
   wire [9:0] 	 wbs_aes_adr_i;     // WISHBONE address input
   wire [3:0] 	 wbs_aes_sel_i;     // WISHBONE byte select input
   wire 	 wbs_aes_we_i;      // WISHBONE write enable input
   wire 	 wbs_aes_cyc_i;     // WISHBONE cycle input
   wire 	 wbs_aes_stb_i;     // WISHBONE strobe input
   wire          wbs_aes_ack_o;     // WISHBONE acknowledge output

   //Global variables
   reg 		 wbm_working; // tasks wbm_write and wbm_read set signal when working and reset it when stop working
   integer 	 tests_successfull;
   integer 	 tests_failed;

   reg [3:0] 	 wbm_init_waits; // initial wait cycles between CYC_O and STB_O of WB Master
   reg [3:0] 	 wbm_subseq_waits; // subsequent wait cycles between STB_Os of WB Master
   reg [3:0] 	 wbs_waits; // wait cycles befor WB Slave responds
   reg [7:0] 	 wbs_retries; // if RTY response, then this is the number of retries before ACK
   reg [799:0]  test_name; // used for tb_log_file

   //Instaciate SD-Card controller

   aes_128_top aes_128_top0
     (
      .aes_clk_in(wb_clk),
      .aes_rst_in(wb_rst),
      .wb_clk_i(wb_clk), 
      .wb_rst_i(wb_rst), 
      .wb_dat_i(wbs_aes_dat_i), 
      .wb_dat_o(wbs_aes_dat_o),
      .wb_adr_i(wbs_aes_adr_i[7:0]), 
      .wb_sel_i(wbs_aes_sel_i), 
      .wb_we_i(wbs_aes_we_i), 
      .wb_cyc_i(wbs_aes_cyc_i), 
      .wb_stb_i(wbs_aes_stb_i), 
      .wb_ack_o(wbs_aes_ack_o)
      );

   WB_MASTER_BEHAVIORAL wb_master
     (
      .CLK_I(wb_clk),
      .RST_I(wb_rst),
      .TAG_I(0), //Not in use
      .TAG_O(), //Not in use
      .ACK_I(wbs_aes_ack_o),
      .ADR_O(wbs_aes_adr_i), // only eth_sl_wb_adr_i[11:2] used
      .CYC_O(wbs_aes_cyc_i),
      .DAT_I(wbs_aes_dat_o),
      .DAT_O(wbs_aes_dat_i),
      .ERR_I(0),  //Not in use
      .RTY_I(1'b0),  // inactive (1'b0)
      .SEL_O(wbs_aes_sel_i),
      .STB_O(wbs_aes_stb_i),
      .WE_O (wbs_aes_we_i),
      .CAB_O()       // NOT USED for now!
      );

   initial
     begin

	// Initial global values
	tests_successfull = 0;
	tests_failed = 0;  
	wbm_working = 0;
	wbm_init_waits = 4'h1;
	wbm_subseq_waits = 4'h3;
	wbs_waits = 4'h1;
	wbs_retries = 8'h2; 

	// set DIFFERENT mrx_clk to mtx_clk!
	//  eth_phy.set_mrx_equal_mtx = 1'b0;

	//  Call tests
	//  ----------
	//note test T5 only valid when SD is in Testmode (sd_tb_defines.v file)
//	$display("T0 Start"); 
	//test_access_to_reg(0, 1);           // 0 - 1 //Test RW registers  
//	$display("");
//	$display("===========================================================================");
//	$display("T0 test_access_to_reg Completed");
//	$display("===========================================================================");

	test_aes();           // 0 - 1 //Test RW registers  
	test_aes();

     end

   // Generating WB_CLK_I clock
   always
     begin
	wb_clk=0;
	//  forever #2.5 WB_CLK_I = ~WB_CLK_I;  // 2*2.5 ns -> 200.0 MHz    
	//  forever #5 WB_CLK_I = ~WB_CLK_I;  // 2*5 ns -> 100.0 MHz    
	//  forever #10 WB_CLK_I = ~WB_CLK_I;  // 2*10 ns -> 50.0 MHz    
	forever #12.5 wb_clk = ~wb_clk;  // 2*12.5 ns -> 40 MHz    
	//  forever #15 WB_CLK_I = ~WB_CLK_I;  // 2*10 ns -> 33.3 MHz    
	//  forever #20 WB_CLK_I = ~WB_CLK_I;  // 2*20 ns -> 25 MHz    
	//  forever #25 WB_CLK_I = ~WB_CLK_I;  // 2*25 ns -> 20.0 MHz
	//  forever #31.25 WB_CLK_I = ~WB_CLK_I;  // 2*31.25 ns -> 16.0 MHz    
	//  forever #50 WB_CLK_I = ~WB_CLK_I;  // 2*50 ns -> 10.0 MHz
	//  forever #55 WB_CLK_I = ~WB_CLK_I;  // 2*55 ns ->  9.1 MHz    
     end

   //TEST Cases
   //
   //
   //

   task test_access_to_reg;
      input  [31:0]  start_task;
      input [31:0]   end_task;
      
      integer        num_of_reg;
      integer        i_addr;
      integer        i_data;
      integer        i_length;
      integer        tmp_data;  
      integer 				 i;
      integer 				 fail;
      integer 				 test_num;
      reg [31:0] 			 addr;
      reg [31:0] 			 data;
      reg [3:0] 			 sel;
      reg [3:0] 			 rand_sel;
      reg [31:0] 			 data_max;
      reg [31:0] 			 rsp;
      
      begin
	 // access_to_reg
	// test_heading("access_to_reg");
	 $display(" ");
	 $display("access_to_reg TEST");
	 fail = 0;

	 // reset MAC registers
	 hard_reset;


	 //////////////////////////////////////////////////////////////////////
	 ////                                                              ////
	 ////  test_access_to_reg:                                          ////
	 ////                                                              ////
	 ////  0:  Read/Write acces register                               ////
	 ///                                             ////
	 //////////////////////////////////////////////////////////////////////
	 for (test_num = start_task; test_num <= end_task; test_num = test_num + 1)
	   begin

	      ////////////////////////////////////////////////////////////////////
	      ////                                                            ////
	      ////  Test all RW register for:                                    ////
	      ////  1: Read access (Correct reset values)                     ////                      
	      ////  2: Write/Read                       ////
	      ////////////////////////////////////////////////////////////////////
	      if (test_num == 0) //
		begin
		   // TEST 0: BYTE SELECTS ON 3 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )
		   test_name   = "TEST 0: 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )";
		   `TIME; $display("  TEST 0: 3 32-BIT READ-WRITE REGISTERS ( VARIOUS BUS DELAYS )");
		   
		   data = 0;
		   rand_sel = 0;
		   sel = 0;
		   
		   for (i = 1; i <= 8; i = i + 1) // num of registers
		     begin
			wbm_init_waits = 0;
			wbm_subseq_waits = {$random} % 5; // it is not important for single accesses
			case (i)
			  1: begin      
			     i_addr = `plain0;
			     data = 32'h0000_00FF;
			  end
			  2:begin      
			     i_addr = `plain1;
			     data = 32'h0000_FFFF;
			  end             
			  3:begin      
			     i_addr = `plain2;
			     data = 32'h0000_FFFF;
			  end       
			  4: begin      
			     i_addr = `plain3;
			     data = 32'h0000_FFFF;
			  end       
			  5:begin      
			     i_addr = `cipher0;
			     data = 32'h0000_FFFF;
			  end         
			  6: begin      
			     i_addr = `cipher1;
			     data = 32'h0000_00FF;
			  end       
			  
			  7: begin      
			     i_addr = `cipher2;
			     data = 32'hFFFF_FFFF;
			  end      
			  
			  8: begin      
			     i_addr = `cipher3;
			     data = 32'hFFFF_FFFF;    
			  end
			  
			  default : begin      
			     i_addr = `plain0;
			     data = 32'h0;    
			  end  		  
			endcase // case (i)
			
			addr = `AES_BASE + i_addr;
			sel = 4'hF;
			wbm_write(addr, data, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
			wait (wbm_working == 0);
			wbm_read(addr, tmp_data, sel, 1, wbm_init_waits, wbm_subseq_waits);
			if (tmp_data !== rsp)
			  begin
			     fail = fail + 1;
			     test_fail_num("Register %h defaultvalue is not RSP ",i_addr);
			     `TIME;
			     $display("Wrong defaulte value @ addr %h, tmp_data %h, should b %h", addr, tmp_data,rsp);
			  end
		     end
		end
	      // Errors were reported previously
	   end
	 if(fail == 0)
	   begin
	      test_ok;
	      $display("test_access_to_reg is successful");
	   end
	 else
	   fail = 0;
      end
   endtask

 task test_aes;
    integer addr;
    
    reg [31:0] data_in;
    reg [31:0] data_out;

    begin
       addr = `AES_BASE + `plain0;
       data_in = 32'h0;
       wbm_write(addr, data_in, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
       addr = `AES_BASE + `plain1;
       data_in = 32'h0;
       wbm_write(addr, data_in, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
       addr = `AES_BASE + `plain2;
       data_in = 32'h0;
       wbm_write(addr, data_in, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
       addr = `AES_BASE + `plain3;
       data_in = 32'h0;
       wbm_write(addr, data_in, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
       
       #1000 addr = `AES_BASE + `cipher0;
       wbm_read(addr, data_out, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
       addr = `AES_BASE + `cipher1;
       wbm_read(addr, data_out, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
       addr = `AES_BASE + `cipher2;
       wbm_read(addr, data_out, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
       addr = `AES_BASE + `cipher3;
       wbm_read(addr, data_out, 4'hF, 1, wbm_init_waits, wbm_subseq_waits);
     end
 endtask

   //Tasks
   task wbm_write;
      input  [31:0] address_i;
      input [31:0]  data_i;
      input [3:0]   sel_i;
      input [31:0]  size_i;
      input [3:0]   init_waits_i;
      input [3:0]   subseq_waits_i;

      reg 	    `WRITE_STIM_TYPE write_data;
      reg 	    `WB_TRANSFER_FLAGS flags;
      reg 	    `WRITE_RETURN_TYPE write_status;
      integer 	    i;
      begin
	 wbm_working = 1;
	 
	 write_status = 0;

	 flags                    = 0;
	 flags`WB_TRANSFER_SIZE   = size_i;
	 flags`INIT_WAITS         = init_waits_i;
	 flags`SUBSEQ_WAITS       = subseq_waits_i;

	 write_data               = 0;
	 write_data`WRITE_DATA    = data_i[31:0];
	 write_data`WRITE_ADDRESS = address_i;
	 write_data`WRITE_SEL     = sel_i;

	 for (i = 0; i < size_i; i = i + 1)
	   begin
	      wb_master.blk_write_data[i] = write_data;
	      data_i                      = data_i >> 32;
	      write_data`WRITE_DATA       = data_i[31:0];
	      write_data`WRITE_ADDRESS    = write_data`WRITE_ADDRESS + 4;
	   end

	 wb_master.wb_block_write(flags, write_status);

	 if (write_status`CYC_ACTUAL_TRANSFER !== size_i)
	   begin
	      `TIME;
	      $display("*E WISHBONE Master was unable to complete the requested write operation to MAC!");
	   end

	 @(posedge wb_clk);
	 #3;
	 wbm_working = 0;
	 #1;
      end
   endtask // wbm_write


   task wbm_read;
      input  [31:0] address_i;
      output [((`MAX_BLK_SIZE * 32) - 1):0] data_o;
      input [3:0] 			    sel_i;
      input [31:0] 			    size_i;
      input [3:0] 			    init_waits_i;
      input [3:0] 			    subseq_waits_i;

      reg 				    `READ_RETURN_TYPE read_data;
      reg 				    `WB_TRANSFER_FLAGS flags;
      reg 				    `READ_RETURN_TYPE read_status;
      integer 				    i;
      begin
	 wbm_working = 1;

	 read_status = 0;
	 data_o      = 0;

	 flags                  = 0;
	 flags`WB_TRANSFER_SIZE = size_i;
	 flags`INIT_WAITS       = init_waits_i;
	 flags`SUBSEQ_WAITS     = subseq_waits_i;

	 read_data              = 0;
	 read_data`READ_ADDRESS = address_i;
	 read_data`READ_SEL     = sel_i;

	 for (i = 0; i < size_i; i = i + 1)
	   begin
	      wb_master.blk_read_data_in[i] = read_data;
	      read_data`READ_ADDRESS        = read_data`READ_ADDRESS + 4;
	   end

	 wb_master.wb_block_read(flags, read_status);

	 if (read_status`CYC_ACTUAL_TRANSFER !== size_i)
	   begin
	      `TIME;
	      $display("*E WISHBONE Master was unable to complete the requested read operation from MAC!");
	   end

	 for (i = 0; i < size_i; i = i + 1)
	   begin
	      data_o       = data_o << 32;
	      read_data    = wb_master.blk_read_data_out[(size_i - 1) - i]; // [31 - i];
	      data_o[31:0] = read_data`READ_DATA;
	   end

	 @(posedge wb_clk);
	 #3;
	 wbm_working = 0;
	 #1;
      end
   endtask // wbm_read

   task hard_reset; //  MAC registers
      begin
	 // reset MAC registers
	 @(posedge wb_clk);
	 #2 wb_rst = 1'b1;
	 repeat(2) @(posedge wb_clk);
	 #2 wb_rst = 1'b0;
      end
   endtask // hard_reset

   task test_fail_num ;
      input [7999:0] failure_reason ;
      input [31:0]   number ;
      //  reg   [8007:0] display_failure ;
      reg [7999:0]   display_failure ;
      reg [799:0]    display_test ;
      begin
	 tests_failed = tests_failed + 1 ;

	 display_failure = failure_reason; // {failure_reason, "!"} ;
	 while ( display_failure[7999:7992] == 0 )
	   display_failure = display_failure << 8 ;

	 display_test = test_name ;
	 while ( display_test[799:792] == 0 )
	   display_test = display_test << 8 ;

	 $display( "    *************************************************************************************" ) ;
	 $display( "    At time: %t ", $time ) ;
	 $display( "    Test: %s", display_test ) ;
	 $display( "    *FAILED* because") ;
	 $display( "    %s; %d", display_failure, number ) ;
	 $display( "    *************************************************************************************" ) ;
	 $display( " " ) ;

`ifdef STOP_ON_FAILURE
	 #20 $stop ;
`endif
      end
   endtask // test_fail_num

   task test_ok ;
      reg [799:0] display_test ;
      begin
	 tests_successfull = tests_successfull + 1 ;

	 display_test = test_name ;
	 while ( display_test[799:792] == 0 )
	   display_test = display_test << 8 ;

	 $display( "    *************************************************************************************" ) ;
	 $display( "    At time: %t ", $time ) ;
	 $display( "    Test: %s", display_test ) ;
	 $display( "    reported *SUCCESSFULL*! ") ;
	 $display( "    *************************************************************************************" ) ;
	 $display( " " ) ;
      end
   endtask // test_ok

endmodule

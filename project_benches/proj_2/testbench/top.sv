`timescale 1ns / 10ps

module top();

  import ncsu_pkg::*;
  import i2c_pkg::*;
  import wb_pkg::*;
  import i2cmb_pkg::*;
  
typedef enum {WRITE=1'b0, READ=1'b1} i2c_op_t;

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;
parameter int I2C_ADDR_WIDTH=7;
parameter int I2C_DATA_WIDTH=8;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_SLAVES-1:0] scl;
triand  [NUM_I2C_SLAVES-1:0] sda;

bit master_op;
bit [I2C_DATA_WIDTH-1:0] write_data_i2c [];
bit [I2C_DATA_WIDTH-1:0] read_data_i2c [64];
bit [I2C_DATA_WIDTH-1:0] read_data_i2c2 [32];

bit [WB_ADDR_WIDTH-1:0] address;
bit [WB_DATA_WIDTH-1:0] data;
bit enable;

bit [I2C_ADDR_WIDTH-1:0] i2c_address;
bit [I2C_DATA_WIDTH-1:0] i2c_data [];
bit i2c_op;

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  .irq_i(irq),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

i2c_if		#(
		.ADDR_WIDTH(I2C_ADDR_WIDTH),
		.DATA_WIDTH(I2C_DATA_WIDTH)
		)
i2c_bus (
	.sda(sda),
	.scl(scl)
 );
// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

// ****************************************************************************
initial
begin
foreach(read_data_i2c2[i])begin
	read_data_i2c2[i] = i+100;
	$display( "Read DATA ::::" , read_data_i2c2[i]);
end
read_data_i2c = {read_data_i2c2, read_data_i2c2};
end

// ****************************************************************************
// Clock generator
initial clk_gen: begin
      clk = 0;
      forever #5 clk = ~clk;
  end
// ****************************************************************************
// Reset generator
initial rst_gen: begin
	rst = 1'b1;
	#113 rst = 1'b0;
end     

i2cmb_test tst;

initial test_flow1: begin
	ncsu_config_db#(virtual wb_if #(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)))::set("tst.env.wb_p0_agent", wb_bus);
    	ncsu_config_db#(virtual i2c_if)::set("tst.env.i2c_p1_agent", i2c_bus);
    	tst = new("tst",null);
    	tst.run();
    	#10ms	 $finish();
end
/*
// ****************************************************************************
// Define the flow of the simulation

initial test_flow: begin
	#1100
	wb_bus.master_write(2'b0,8'b11xxxxxx); //
	wb_bus.master_write(2'b01,8'h01);	//Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
	wb_bus.master_write(2'b10,8'bxxxxx110); //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
	while(irq == 1'b0);	//Wait for interrupt or until DON bit of CMDR reads '1'.
	wb_bus.master_read(2'b10,data);	

//start
	wb_bus.master_write(2'b10,8'bxxxxx100); //Write byte “xxxxx100” to the CMDR. This is Start command.
	while(irq == 1'b0) @(posedge clk);
	wb_bus.master_read(2'b10,data);
	
// Address
	wb_bus.master_write(2'b01,8'h44); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
	wb_bus.master_write(2'b10,8'bxxxxx001); //Write byte “xxxxx001” to the CMDR. This is Write command.
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
	
//Data
	for(byte i = 0; i < 32; i++) begin
		wb_bus.master_write(2'b01,i); //Write byte 0x78 to the DPR. This is the byte to be written.
		wb_bus.master_write(2'b10,8'bxxxxx001);//Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10,data);
	end

//stop
	wb_bus.master_write(2'b10,8'bxxxxx101);//Write byte “xxxxx101” to the CMDR. This is Stop command.
	while(irq == 1'b0) @(posedge clk);	
	wb_bus.master_read(2'b10,data);
		
// Read 

// Start
	wb_bus.master_write(2'b10,8'bxxxxx100); //Write byte “xxxxx100” to the CMDR. This is Start command.
	while(irq == 1'b0) @(posedge clk);
	wb_bus.master_read(2'b10,data);

// Address
	wb_bus.master_write(2'b01,8'h45); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
	wb_bus.master_write(2'b10,8'bxxxxx001); //Write byte “xxxxx001” to the CMDR. This is Write command.
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
//Data
	for(byte i = 0; i < 31; i++) begin
		wb_bus.master_write(2'b10,8'bxxxxx010); //Write byte “xxxxx011” to the CMDR. This is read with nack command
		while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10,data);
		wb_bus.master_read(2'b01,data);// read dpr
	end
	
	wb_bus.master_write(2'b10,8'bxxxxx011); //Write byte “xxxxx011” to the CMDR. This is read with nack command
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
	wb_bus.master_read(2'b01,data);// read dpr

//alternate read/write

	for(byte alt=0;alt<32;alt++)
	begin
//  start

		wb_bus.master_write(2'b10,8'bxxxxx100); //Write byte “xxxxx100” to the CMDR. This is Start command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10,data);

	
// Address
		wb_bus.master_write(2'b01,8'h88); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
		wb_bus.master_write(2'b10,8'bxxxxx001); //Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10,data);

//data	
		wb_bus.master_write(2'b01,(alt)); //Write byte 0x78 to the DPR. This is the byte to be written.
		wb_bus.master_write(2'b10,8'bxxxxx001);//Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10,data);

//repeated start
		wb_bus.master_write(2'b10,8'bxxxxx100); //Write byte “xxxxx100” to the CMDR. This is Start command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10,data);

// Address
		wb_bus.master_write(2'b01,8'h89); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
		wb_bus.master_write(2'b10,8'bxxxxx001); //Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10,data);

//data
		wb_bus.master_write(2'b10,8'bxxxxx011); //Write byte “xxxxx011” to the CMDR. This is read with nack command
		while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10,data);
		wb_bus.master_read(2'b01,data);// read dpr


	end

//stop
	wb_bus.master_write(2'b10,8'bxxxxx101);//Write byte “xxxxx101” to the CMDR. This is Stop command.
	while(irq == 1'b0) @(posedge clk);	
	wb_bus.master_read(2'b10,data);

	#1000 $finish;
end*/
/*
initial
begin:test_flow
	#1100
	wb_bus.master_write(2'b0,8'b11xxxxxx); //
	wb_bus.master_write(2'b01,8'h01);	//Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
	wb_bus.master_write(2'b10,8'bxxxxx110); //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
	while(irq == 1'b0);	//Wait for interrupt or until DON bit of CMDR reads '1'.
	wb_bus.master_read(2'b10,data);	
	
	wb_bus.master_write(2'b10,8'bxxxxx100); //Write byte “xxxxx100” to the CMDR. This is Start command.
	while(irq == 1'b0) @(posedge clk);
	wb_bus.master_read(2'b10,data);
	
	wb_bus.master_write(2'b01,8'h89); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
	wb_bus.master_write(2'b10,8'bxxxxx001); //Write byte “xxxxx001” to the CMDR. This is Write command.
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
	
	wb_bus.master_write(2'b10,8'bxxxxx010); //Write byte “xxxxx010” to the CMDR. This is read with ack command.
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);	
	wb_bus.master_read(2'b01,data); // read dpr
	
	wb_bus.master_write(2'b10,8'bxxxxx010); //Write byte “xxxxx011” to the CMDR. This is read with nack command
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
	wb_bus.master_read(2'b01,data);// read dpr

	wb_bus.master_write(2'b10,8'bxxxxx010); //Write byte “xxxxx011” to the CMDR. This is read with nack command
	while(irq == 1'bMakefile  t0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
	wb_bus.master_read(2'b01,data);// read dpr

	wb_bus.master_write(2'b10,8'bxxxxx011); //Write byte “xxxxx011” to the CMDR. This is read with nack command
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
	wb_bus.master_read(2'b01,data);// read dpr

	wb_bus.master_write(2'b10,8'bxxxxx101);//Write byte “xxxxx101” to the CMDR. This is Stop command.
	while(irq == 1'b0) @(posedge clk);	
	wb_bus.master_read(2'b10,data);
	#1000000 $finish;
	

end*/



endmodule

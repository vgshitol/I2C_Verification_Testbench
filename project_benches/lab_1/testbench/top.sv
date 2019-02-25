`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;

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
tri  [NUM_I2C_SLAVES-1:0] sda;

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


// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
initial wb_monitoring: begin
	logic [WB_ADDR_WIDTH-1:0] addr;
	logic [WB_DATA_WIDTH-1:0] data;	
	logic w_en;

	forever begin
			#1 wb_bus.master_monitor(addr, data, w_en); 
			$display("Addr:0x%x | Data:0x%x | W_En:%x \n", addr,data,w_en );			
		
	end
end
// ****************************************************************************
// Define the flow of the simulation
initial test_flow: begin
	logic [WB_ADDR_WIDTH-1:0] addr_w;
	logic [WB_DATA_WIDTH-1:0] data_w;	

	logic [WB_ADDR_WIDTH-1:0] addr_r;
	logic [WB_DATA_WIDTH-1:0] data_r;	
	
//example 1 csr	 
	#400 addr_w = 8'h00;
	     data_w = 8'b11xxxxxx;	 
	     wb_bus.master_write(addr_w, data_w); 	
	
//example 3 dpr
	 addr_w = 8'h01;
	 data_w = 8'h05;	 
	 wb_bus.master_write(addr_w, data_w);

//cmdr set bus command
	 addr_w = 8'h02;
         data_w = 8'bxxxxx110;	 
	 wb_bus.master_write(addr_w, data_w);

//wait for interrupt
	addr_r = 8'h02;
	wait(irq);
	wb_bus.master_read(addr_r, data_r);
	wait(!irq);
	
//cmdr start
	addr_w = 8'h02;
	data_w = 8'bxxxxx100;	 
	wb_bus.master_write(addr_w, data_w);

//wait for interrupt
	addr_r = 8'h02;
	wait(irq);
	wb_bus.master_read(addr_r, data_r);
	wait(!irq);
	
//0x44 dpr
	addr_w = 8'h01;
	data_w = 8'h44;	 
	wb_bus.master_write(addr_w, data_w);

//cmdr write
	addr_w = 8'h02;
	data_w = 8'bxxxxx001;	 
	wb_bus.master_write(addr_w, data_w);


//wait for interrupt
	addr_r = 8'h02;
	wait(irq);
	if(data_r[7]==0 && data_r[6]==1) begin
		$display("NAK Bit is High \n" );
	end
	wb_bus.master_read(addr_r, data_r);
	wait(!irq);

//0x78 dpr
	addr_w = 8'h01;
	data_w = 8'h78;	 
	wb_bus.master_write(addr_w, data_w);

//cmdr write
	addr_w = 8'h02;
	data_w = 8'bxxxxx001;	 
	wb_bus.master_write(addr_w, data_w);


//wait for interrupt
	addr_r = 8'h02;
	wait(irq);
	wb_bus.master_read(addr_r, data_r);
	wait(!irq);
	
//cmdr stop
	addr_w = 8'h02;
	data_w = 8'bxxxxx101;	 
	wb_bus.master_write(addr_w, data_w);


//wait for interrupt
	addr_r = 8'h02;
	wait(irq);
	wb_bus.master_read(addr_r, data_r);
	wait(!irq);

$display("DONE");

#1000 $finish;
	
end

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


endmodule

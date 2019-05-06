`timescale 1ns/10ps

module top();

  import ncsu_pkg::*;
  import wb_pkg::*;
  import i2c_pkg::*;
  import i2cmb_env_pkg::*;
  //import i2c_variables::*;


parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;
parameter int ADDR_WIDTH_I2C=7;
parameter int DATA_WIDTH_I2C=8;

bit  clk;
bit  rst_n = 1'b1;
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

// ****************************************************************************
// Clock generator
initial
begin:clk_gen
	forever
	begin
		#5 clk=~clk;
	end 
	// #500 $finish;
end

// ****************************************************************************
// Reset generator
//bit rst_n;
   initial begin : rst_gen
      #113ns rst_n = 1'b0;
   end

   i2cmb_test tst;


// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst_n),
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
// ****************************************************************************
// Instantiate the I2C slave interface
i2c_if		#(
		.I2C_ADDR_WIDTH(ADDR_WIDTH_I2C),
		.I2C_DATA_WIDTH(DATA_WIDTH_I2C)
		)
i2c_bus (
	.sda_i2c(sda),
	.scl_i2c(scl)
 );
// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst_n),         // in    std_logic;                            -- Synchronous reset (active high)
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



  property irqTest;
    @(posedge clk) disable iff (rst_n)
        (adr == 2'b10) && (dat_wr_o == 8'b1xxxxxxx || dat_wr_o == 8'bx1xxxxxx || dat_wr_o == 8'bxx1xxxxx || dat_wr_o == 8'bxxx1xxxx) |=> irq;
  endproperty

  assert property(irqTest) else $fatal("irq signal failure");

  property strobeTest;
    @(posedge clk) disable iff (rst_n)
        (!stb) || (stb && cyc);
  endproperty

  assert property(strobeTest) else $fatal("Strobe is High even when CYC is low");

// ****************************************************************************
  initial begin : test_flow
    ncsu_config_db#(virtual wb_if)::set("tst.env.WBagent", wb_bus);
    ncsu_config_db#(virtual i2c_if)::set("tst.env.I2Cagent", i2c_bus);
    tst = new("tst",null);
    tst.run();
    #50000000ns $finish();
  end



endmodule

class wb_coverage extends ncsu_component#(.T(wb_transaction));

  wb_configuration configuration;

  bit [1:0] wb_addr;
  bit [7:0] wb_data;
  bit         wb_we;

  reg_type_t reg_type;
  we_type_t we_type;
  bit [7:0] reset_data;
  bit [7:0] disable_core, enable_core;
  bit [31:0] address_validity;


  covergroup Register_cg;
    option.per_instance = 1;
    option.name = get_full_name();

    reg_type : coverpoint reg_type
        {
          bins CSR = {CSR};
          bins DPR = {DPR};
          bins CMDR = {CMDR};
          bins FSMR = {FSMR};
        }

    we_type: coverpoint we_type
        {
          bins WB_READ = {WB_READ};
          bins WB_WRITE = {WB_WRITE};
        }

    reg_type_x_we_type: cross reg_type, we_type //register access check
        {
          illegal_bins FSMR_ACCESS = binsof(reg_type.FSMR) && binsof(we_type.WB_WRITE);
        }

    address_validity: coverpoint address_validity
        {
          bins VALID_ADDR = {['h0:'h3]};
          // illegal_bins INVAILD_ADDR = {['h4:$]};
          illegal_bins INVAILD_ADDR = default;
        }

    wb_addr: coverpoint wb_addr // for register directed tests
        {
          // bit access check
          bins WB_ADDRESS_CSR  = ('h0 =>'h0 => 'h0); //csr
          bins WB_ADDRESS_DPR  = ('h1 =>'h1 => 'h1); //dpr
          bins WB_ADDRESS_CMDR = ('h2 =>'h2 => 'h2); //cmdr
          bins WB_ADDRESS_FSMR = ('h3 =>'h3 => 'h3); //fsmr
          //aliasing
          bins WB_ADDRESS_CSR_AL  = ('h0 =>'h0 => 'h0); //csr
          bins WB_ADDRESS_DPR_AL  = ('h1 =>'h1 => 'h1); //dpr
          bins WB_ADDRESS_CMDR_AL = ('h2 =>'h2 => 'h2); //cmdr
          bins WB_ADDRESS_FSMR_AL = ('h3 =>'h3 => 'h3); //fsmr
        }

    wb_we: coverpoint wb_we // for register directed tests
        {
          // bit access check
          bins WB_WE_CSR  = (1'b0 => 1'b1 => 1'b0); //csr
          bins WB_WE_DPR  = (1'b0 => 1'b1 => 1'b0); //dpr
          bins WB_WE_CMDR = (1'b0 => 1'b1 => 1'b0); //cmdr
          bins WB_WE_FSMR = (1'b0 => 1'b1 => 1'b0); //fsmr

          //aliasing
          bins WB_WE_CSR_AL  = (1'b1 => 1'b0 => 1'b0); //csr
          bins WB_WE_DPR_AL  = (1'b1 => 1'b0 => 1'b0); //dpr
          bins WB_WE_CMDR_AL = (1'b1 => 1'b0 => 1'b0); //cmdr
          bins WB_WE_FSMR_AL = (1'b0 => 1'b0 => 1'b0); //fsmr

        }

    wb_data: coverpoint wb_data // for register directed tests
        {
          // bit access check
          bins WB_DATA_CSR  = ('h0 => 'h3F =>  'h0); //csr
          bins WB_DATA_DPR  = ('h0 => 'hFF => 'hFF); //dpr
          bins WB_DATA_CMDR = ('h80 => 'hFF =>'h87); //cmdr
          bins WB_DATA_FSMR = ('h0 => 'hFF =>  'h0); //fsmr

          //aliasing
          bins WB_DATA_CSR_AL  = ('hC0 => 'hC0 =>  'h0); //csr
          bins WB_DATA_DPR_AL  = ('hFF => 'hFF => 'hFF); //dpr
          bins WB_DATA_CMDR_AL = ('h04 => 'h04 =>'h04); //cmdr
          bins WB_DATA_FSMR_AL = ('h0 => 'hFF =>  'h0); //fsmr

        }

    reg_bit_access_aliasing_check: cross wb_addr,wb_data,wb_we; // reg bit access checks and register aliasing

    reset_data: coverpoint reset_data
        {
          bins CSR_RESET  = {RESET_CSR};
          bins DPR_RESET  = {RESET_DPR};
          bins CMDR_RESET = {RESET_CMDR};
          bins FSMR_RESET = {RESET_FSMR};
        }

    disable_core: coverpoint disable_core
        {
          bins DISABLE_CORE ={DISABLE_CORE};
        }

    enable_core: coverpoint enable_core
        {
          bins ENABLE_CORE = {ENABLE_CORE};
        }

    reset_data_x_ed_core: cross reset_data, disable_core;
    // {
    //   illegal_bins CMDR_R_DATA = binsof(reset_data.CMDR_RESET) && binsof(disable_core.DISABLE_CORE);
    // }

  endgroup

  function new(string name = "", ncsu_component #(T) parent = null);
    super.new(name,parent);
    Register_cg = new;
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    // $display("wb_coverage::nb_put() %s called",get_full_name());

    reg_type = reg_type_t'(trans.addr);
    we_type = we_type_t'(trans.enable);
    address_validity = trans.addr;
    wb_addr = trans.addr;
    wb_we = trans.enable;
    wb_data = trans.data;

    if(trans.addr == 'h0) begin
      enable_core = trans.data;
      disable_core = trans.data;
    end

    Register_cg.sample();
  endfunction

endclass

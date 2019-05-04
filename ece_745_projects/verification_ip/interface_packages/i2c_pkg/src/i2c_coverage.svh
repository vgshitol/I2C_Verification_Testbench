class i2c_coverage extends ncsu_component#(.T(i2c_transaction));

        i2c_configuration configuration;
  	bit[3:0] temp;
  
  covergroup i2c_transaction_cg;
  	option.per_instance = 1;
        option.name = get_full_name();
  	temp: coverpoint temp;
  endgroup

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
    i2c_transaction_cg = new;
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    $display("abc_coverage::nb_put() %s called",get_full_name());
    temp = trans.i2c_address[3:0];
    i2c_transaction_cg.sample();
  endfunction
	
endclass

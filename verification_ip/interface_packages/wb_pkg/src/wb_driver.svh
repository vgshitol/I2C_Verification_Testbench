class wb_driver extends ncsu_component#(.T(wb_transaction));

    virtual wb_if #(.ADDR_WIDTH(2), .DATA_WIDTH(8)) bus;
    wb_configuration configuration;
    wb_transaction wb_trans;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(wb_configuration cfg);
        configuration = cfg;
    endfunction

    virtual task bl_put(T trans);
     //   $display({get_full_name()," ",trans.convert2string()});
      	bus.wait_for_reset();
	 $display(" \nWB DRIVER Address%x Data%x Operation %d INTERRUPT\t%d\n",trans.address,trans.data, trans.rw, trans.intr);
	
	if(trans.rw == 0) begin 
		bus.master_write(trans.address, trans.data);
	end
	else begin
		bus.master_read(trans.address, trans.data);
	end
	if(trans.intr==1) bus.wait_for_interrupt();
	
    endtask

endclass

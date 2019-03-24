class i2c_driver extends ncsu_component#(.T(i2c_transaction));

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    virtual i2c_if #(.ADDR_WIDTH(7), .DATA_WIDTH(8)) bus;
    i2c_configuration configuration;
    i2c_transaction i2c_trans;

    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    virtual task bl_put(T trans);
        bit [7:0] read_data_i2c [64];
        bit [7:0] read_data_i2c2 [32];
        foreach(read_data_i2c2[i])begin
                read_data_i2c2[i] = i+100;
                $display( "Read DATA ::::" , read_data_i2c2[i]);
            end
            read_data_i2c = {read_data_i2c2, read_data_i2c2};
        end
    trans.read_data = read_data_i2c2;
  //      $display({get_full_name()," ",trans.convert2string()});
//	$display("I2C_DRIVER BEFORE ");
        bus.wait_for_i2c_transfer(trans.op, trans.write_data);
	//$display("I2C_DRIVER HAPPENS ");
        if(trans.op == 1) begin
            bus.provide_read_data(trans.read_data);
        end
    endtask
endclass

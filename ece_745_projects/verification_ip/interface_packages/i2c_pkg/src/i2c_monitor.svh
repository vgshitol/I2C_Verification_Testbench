class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

    i2c_configuration  configuration;
    virtual i2c_if bus;

    T monitored_trans;
    ncsu_component #(T) agent;

    function new(string name = "", ncsu_component #(T) parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    function void set_agent(ncsu_component#(T) agent);
        this.agent = agent;
    endfunction

    virtual task run ();
        forever begin
            monitored_trans = new("monitored_trans");
            bus.monitor(monitored_trans.i2c_address,monitored_trans.op,monitored_trans.i2c_data
                );
            if(monitored_trans.op == 1)
                $display("%s I2C Data %p , I2C Address:  0x%x ,  Operation: READ",
                    get_full_name(),
                    monitored_trans.i2c_data,monitored_trans.i2c_address
                    );
            else
                $display("%s I2C Data %p , I2C Address:  0x%x ,  Operation: WRITE",
                    get_full_name(),
                    monitored_trans.i2c_data,monitored_trans.i2c_address
                    );
            agent.nb_put(monitored_trans);
        end
    endtask

endclass

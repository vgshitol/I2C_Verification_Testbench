class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

    i2c_configuration  configuration;
    virtual i2c_if bus;

    T monitored_trans;
    ncsu_component #(T) agent;

    function new(string name = "", ncsu_component_base parent = null);
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
            monitored_trans = new("monitor_trans");
            bus.monitor(
                monitored_trans.monitor_address,
                monitored_trans.monitor_op,
                monitored_trans.monitor_data
                );
            $display("%s i2c_monitor::run() Address: 0x%x Operation: 0x%x Data: 0x%p",
                get_full_name(),
                monitored_trans.monitor_address,
                monitored_trans.monitor_op,
                monitored_trans.monitor_data
                );
            agent.nb_put(monitored_trans);
        end
    endtask

endclass

class wb_monitor extends ncsu_component#(.T(wb_transaction));

    wb_configuration  configuration;
    virtual wb_if bus;

    T monitored_trans;
    ncsu_component #(T) agent;

    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(wb_configuration cfg);
        configuration = cfg;
    endfunction

    function void set_agent(ncsu_component#(T) agent);
        this.agent = agent;
    endfunction

    virtual task run ();
        bus.wait_for_reset();
        forever begin
            monitored_trans = new("monitored_trans");
            bus.master_monitor(monitored_trans.addr,
                monitored_trans.data,
                monitored_trans.enable
                );
            $display("%s WISHBONE_MONITOR::run()WB ADDR: 0x%x | WB DATA:  0x%x | WB ENABLE: %d",
                get_full_name(),
                monitored_trans.addr,
                monitored_trans.data ,
                monitored_trans.enable
                );
            agent.nb_put(monitored_trans);
        end
    endtask

endclass

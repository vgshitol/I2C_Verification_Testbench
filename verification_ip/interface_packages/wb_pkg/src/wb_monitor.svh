class wb_monitor extends ncsu_component#(.T(wb_transaction));

    wb_configuration  configuration;
    virtual wb_if bus;

    T monitored_trans;
    ncsu_component#(T) agent;

    function new(string name = "", ncsu_component_base parent = null);
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
            bus.monitor(monitored_trans.header,
                monitored_trans.payload,
                monitored_trans.trailer,
                monitored_trans.delay
                );
            $display("%s wb_monitor::run() header 0x%x payload 0x%p trailer 0x%x delay 0x%x",
                get_full_name(),
                monitored_trans.header,
                monitored_trans.payload,
                monitored_trans.trailer,
                monitored_trans.delay
                );
            agent.nb_put(monitored_trans);
        end
    endtask

endclass

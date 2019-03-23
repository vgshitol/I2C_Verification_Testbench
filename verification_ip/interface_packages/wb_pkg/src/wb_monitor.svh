class wb_monitor extends ncsu_component#(.T(wb_transaction));

    wb_configuration  configuration;
    virtual wb_if  #(
      .ADDR_WIDTH(2),
      .DATA_WIDTH(8)
      ) bus;

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
         forever begin
         #1   monitored_trans = new("monitored_trans");
            bus.master_monitor(monitored_trans.address,
                monitored_trans.data,
                monitored_trans.rw
                );
            $display("%s wb_monitor::run() Address: 0x%x Data: 0x%p Operation %d",
                get_full_name(),
                monitored_trans.address,
                monitored_trans.data,
                monitored_trans.rw
                );
            agent.nb_put(monitored_trans);
        end
    endtask

endclass

class i2cmb_environment extends ncsu_component#(.T(wb_transaction));

    i2cmb_env_configuration configuration;
    wb_agent         	    wb_p0_agent;
    i2c_agent         	    i2c_p1_agent;
    i2cmb_predictor         pred;
    //i2cmb_scoreboard        scbd;
    i2cmb_coverage          coverage;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void build();
        wb_p0_agent = new("wb_p0_agent",this);
        wb_p0_agent.set_configuration(configuration.wb_p0_agent_config);
        wb_p0_agent.build();
        i2c_p1_agent = new("i2c_p1_agent",this);
        i2c_p1_agent.set_configuration(configuration.i2c_p1_agent_config);
        i2c_p1_agent.build();
        pred  = new("pred", this);
        pred.set_configuration(configuration);
        pred.build();
      //  scbd  = new("scbd", this);
       // scbd.build();
        coverage = new("coverage", this);
        coverage.set_configuration(configuration);
        coverage.build();
        wb_p0_agent.connect_subscriber(coverage);
        wb_p0_agent.connect_subscriber(pred);
       // pred.set_scoreboard(scbd);
    //    i2c_p1_agent.connect_subscriber(scbd);
    endfunction

    function ncsu_component#(.T(wb_transaction)) get_wb_p0_agent();
        return wb_p0_agent;
    endfunction

    function ncsu_component#(.T(i2c_transaction))  get_i2c_p1_agent();
        return i2c_p1_agent;
    endfunction

    virtual task run();
        wb_p0_agent.run();
        i2c_p1_agent.run();
    endtask

endclass

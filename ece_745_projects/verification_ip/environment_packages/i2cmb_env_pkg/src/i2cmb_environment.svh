class i2cmb_environment extends ncsu_component#(.T(ncsu_transaction));

    i2cmb_env_configuration configuration;
    wb_agent         WBagent;
    i2c_agent	   I2Cagent;
    predictor        pred;
    scoreboard       scbd;
    i2cmb_coverage   coverage;

    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void build();
        WBagent = new("WBagent",this);
        WBagent.set_configuration(configuration.WB_agent_config);
        WBagent.build();
        I2Cagent = new("I2Cagent",this);
        I2Cagent.set_configuration(configuration.I2C_agent_config);
        I2Cagent.build();
        pred  = new("Predictor", this);
        pred.set_configuration(configuration);
        pred.build();
        scbd  = new("Scoreboard", this);
        scbd.build();
        coverage = new("coverage", this);
        coverage.set_configuration(configuration);
        coverage.build();
        WBagent.connect_subscriber(coverage);
        WBagent.connect_subscriber(pred);
        pred.set_scoreboard(scbd);
        I2Cagent.connect_subscriber(scbd);
    endfunction

    function ncsu_component#(wb_transaction) get_wb_p0_agent();
        return WBagent;
    endfunction

    function ncsu_component#(i2c_transaction) get_i2c_p1_agent();
        return I2Cagent;
    endfunction

    virtual task run();
        WBagent.run();
        I2Cagent.run();
    endtask

endclass

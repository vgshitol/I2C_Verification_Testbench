class i2cmb_test extends ncsu_component#(.T(ncsu_transaction));

    i2cmb_env_configuration  cfg;
    i2cmb_environment        env;
    i2cmb_generator          gen;


    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        cfg = new("cfg");
        //cfg.sample_coverage();
        env = new("env",this);
        env.set_configuration(cfg);
        env.build();
        gen = new("gen",this);
        gen.set_wb_agent(env.get_WB_agent());
        gen.set_i2c_agent(env.get_I2C_agent());
    endfunction

    virtual task run();
        env.run();
        gen.run();
    endtask

endclass

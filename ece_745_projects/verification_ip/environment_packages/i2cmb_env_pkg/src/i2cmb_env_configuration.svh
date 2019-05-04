class i2cmb_env_configuration extends ncsu_configuration;

    bit       loopback;
    bit       invert;
    bit [3:0] port_delay;

    // Dummy Covergroup at the moment to decide what to put in it at a later stage
    covergroup env_configuration_cg;
        option.per_instance = 1;
        option.name = name;
        coverpoint loopback;
        coverpoint invert;
        coverpoint port_delay;
    endgroup

    function void sample_coverage();
        env_configuration_cg.sample();
    endfunction

    wb_configuration WB_agent_config;
    i2c_configuration I2C_agent_config;

    function new(string name="");
        super.new(name);
        env_configuration_cg = new;
        WB_agent_config = new("WB_agent_config");
        I2C_agent_config = new("I2C_agent_config");
        I2C_agent_config.collect_coverage=0;
        WB_agent_config.collect_coverage=1;
        WB_agent_config.sample_coverage();
        I2C_agent_config.sample_coverage();
    endfunction

endclass

class i2cmb_coverage extends ncsu_component#(.T(i2c_transaction));

    i2cmb_env_configuration     configuration;
    i2c_transaction  coverage_transaction;
    bit                   loopback;
    bit                   invert;

    covergroup coverage_cg;
        option.per_instance = 1;
        option.name = get_full_name();
        loopback:    coverpoint loopback;
        invert:      coverpoint invert;
    endgroup

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        coverage_cg = new;
    endfunction

    virtual function void nb_put(T trans);
        $display({get_full_name()," ",trans.convert2string()});
        loopback    = configuration.loopback;
        invert      = configuration.invert;
        coverage_cg.sample();
    endfunction

endclass

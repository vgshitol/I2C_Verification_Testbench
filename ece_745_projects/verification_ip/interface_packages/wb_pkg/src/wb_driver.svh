class wb_driver extends ncsu_component#(.T(wb_transaction));

    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
    endfunction

    virtual wb_if bus;
    wb_configuration configuration;
    wb_transaction wb_trans;

    function void set_configuration(wb_configuration cfg);
        configuration = cfg;
    endfunction

    virtual task bl_put(T trans);
        //$display({get_full_name()," ",trans.convert2string()});
        if(trans.irq_c==1)
            bus.wait_for_interrupt();

        else
            begin
                if(trans.type_op==1) begin
                    bus.wait_for_num_clocks(trans.delay);
                    bus.master_write(trans.addr,
                        trans.data
                        );
                end
                else begin
                    bus.wait_for_num_clocks(trans.delay);
                    bus.master_read(trans.addr,
                        trans.data
                        );
                end
            end
    endtask

endclass

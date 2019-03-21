// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(abc_transaction_base));
class i2cmb_generator extends ncsu_component#(.T(wb_transaction));

   // wb_transaction transaction[10];
    wb_transaction transaction;
    ncsu_component #(T) agent;
    string trans_name;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
            $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
            $fatal;
        end
        $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
    endfunction

    virtual task run();
//        foreach (transaction[i]) begin
//            $cast(transaction[i],ncsu_object_factory::create(trans_name));
//            assert (transaction[i].randomize());
//            agent.bl_put(transaction[i]);
//            $display({get_full_name()," ",transaction[i].convert2string()});
//        end
        $cast(transaction,ncsu_object_factory::create(trans_name));
        //assert (transaction);
        transaction.
        agent.bl_put(transaction);
        $display({get_full_name()," ",transaction.convert2string()});
    endtask

    function void set_agent(ncsu_component #(T) agent);
        this.agent = agent;
    endfunction

endclass
